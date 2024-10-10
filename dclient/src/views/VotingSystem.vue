<template>
  <div class="container">
    <div class="carousel-container">
      <n-carousel autoplay class="carousel" :dot-type="'line'" style="height: 180px">
        <img class="carousel-img" src="https://image-assets.mihuashi.com/artwork-carousel/5.jpg">
        <img class="carousel-img" src="https://image-assets.mihuashi.com/artwork-carousel/2.jpg">
        <img class="carousel-img" src="https://image-assets.mihuashi.com/artwork-carousel/3.jpg">
        <img class="carousel-img" src="https://image-assets.mihuashi.com/artwork-carousel/4.jpg">
      </n-carousel>
    </div>


    <div class="post-container">
      <n-button @click="showPostModal" class="post-button" size="large" strong secondary circle type="primary">
        Create Voting
      </n-button>

      <n-modal v-model:show="postModalFlag" :style="{ width: '600px' }" preset="card" size="huge"
        :bordered="false">
        <n-form ref="formRef" :model="post_vote" label-placement="left" label-width="auto"
          require-mark-placement="right-hanging">
          <n-form-item label="创建者" path="inputValue">
            <n-input v-model:value="post_vote.creator" placeholder="Creator" />
          </n-form-item>
          <n-form-item label="名称" path="inputValue">
            <n-input v-model:value="post_vote.name" placeholder="Name" />
          </n-form-item>
          <n-form-item label="奖励金额" path="inputNumberValue">
            <n-input-number v-model:value="post_vote.rewardAmount" placeholder="Reward Amount" />
            <div>&nbsp;&nbsp; × 1e12 Wei(ETH-6)</div>
          </n-form-item>
          
          <div style="display: flex; justify-content: flex-end">
            <n-button round type="primary" @click="postSubmit">
              Post
            </n-button>
          </div>
        </n-form>
      </n-modal>
    </div>

    <div class="content-container">
      <n-grid :x-gap="12" :y-gap="8" :cols="1">
        <n-gi v-for="vote in votes" :key="vote.id">
          <CardVue :title="vote.name" 
            :author="vote.creator" 
            :price="vote.rewardAmount" 
            :id="vote.id" 
            :candidates="vote.candidates" 
            :ended="vote.ended" 
            :winner="vote.winner" 
            :img="'../assets/logo.png'" @joinVote="joinVote" @vote="castVote"></CardVue>
        </n-gi>
      </n-grid>
    </div>

    <div class="merkle-tree-container">
      <h3>Merkle Tree</h3>
      <ul>
        <li v-for="(node, index) in merkleTree" :key="index">
          <strong>Node {{ index }}:</strong> {{ node.hash }}
          <ul v-if="node.children.length">
            <li v-for="(child, childIndex) in node.children" :key="childIndex">
              Child_Hash: {{ child.hash }}
            </li>
          </ul>
        </li>
      </ul>
    </div>


  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import {
  NCarousel, NCarouselItem,
  NButton, NModal, NForm, NFormItem, NInput, NInputNumber,
  NGrid, NGi, NAffix,
} from 'naive-ui';
import CardVue from '@/components/Card.vue';
import CryptoJS from 'crypto-js';

// 初始化合约以及连接MetaMask
const contract = require('@truffle/contract');
const artifact = require('../assets/contracts/VotingSystem.json');
const VotingSystemContract = contract(artifact);
VotingSystemContract.setProvider(window.ethereum);

/*************************** Merkle相关 **********************/
const votesData = ref([]);  // voting hash
const merkleRoot = ref(null);
const merkleProof = ref(null);
const verificationResult = ref(null);
const merkleTree = ref([]);

console.log(merkleRoot)

const hashVote = (vote) => {
  return CryptoJS.SHA256(vote).toString();
};

const buildMerkleTree = (leaves) => {
  if (leaves.length === 0) return [];
  
  let nodes = leaves.map(leaf => ({ hash: leaf, children: [] }));
  const tree = [nodes];
  
  while (nodes.length > 1) {
    if (nodes.length % 2 !== 0) {
      nodes.push(nodes[nodes.length - 1]);
    }
    const newLevel = [];
    for (let i = 0; i < nodes.length; i += 2) {
      const combinedHash = CryptoJS.SHA256(nodes[i].hash + nodes[i + 1].hash).toString();
      newLevel.push({
        hash: combinedHash,
        children: [nodes[i], nodes[i + 1]],
      });
    }
    nodes = newLevel;
    tree.push(nodes);
  }
  return tree;
};

const generateMerkleProof = (index, leaves) => {
  let proof = [];
  let nodes = [...leaves];
  while (nodes.length > 1) {
    if (nodes.length % 2 !== 0) {
      nodes.push(nodes[nodes.length - 1]);
    }
    const newLevel = [];
    for (let i = 0; i < nodes.length; i += 2) {
      if (i === index || i + 1 === index) {
        proof.push(i === index ? nodes[i + 1] : nodes[i]);
      }
      newLevel.push(CryptoJS.SHA256(nodes[i] + nodes[i + 1]).toString());
    }
    index = Math.floor(index / 2);
    nodes = newLevel;
  }
  return proof;
};

const verifyProof = (leaf, root, proof) => {
  let hash = leaf;
  proof.forEach((siblingHash) => {
    if (hash < siblingHash) {
      hash = CryptoJS.SHA256(hash + siblingHash).toString();
    } else {
      hash = CryptoJS.SHA256(siblingHash + hash).toString();
    }
  });
  return hash === root;
};

const submitVote = (vote) => {
  const hashedVote = hashVote(vote);
  votesData.value.push(hashedVote);
  const tree = buildMerkleTree(votesData.value);
  merkleTree.value = tree.flat();
  merkleRoot.value = tree[tree.length - 1][0];
};

const generateAndVerifyProof = (vote) => {
  const hashedVote = hashVote(vote);
  const index = votesData.value.indexOf(hashedVote);
  if (index === -1) {
    alert('Vote not found');
    return;
  }
  merkleProof.value = generateMerkleProof(index, votesData.value);
  verificationResult.value = verifyProof(hashedVote, merkleRoot.value, merkleProof.value);
};

const initMerkleTree = () => {
  votesData.value = [];
  merkleRoot.value = null;
  merkleProof.value = null;
  verificationResult.value = null;
  merkleTree.value = [];
};
initMerkleTree();
/*************************** end Merkle **********************/

/*************************** votes相关 *******************************/
// 获得votes并在页面中显示
// 获取事件的报错
const votes = ref([]);
const errorMessages = ref([]);

const loadPostedData = () => {
  VotingSystemContract.deployed().then((instance) => {
    return instance.getVotes.call();
  }).then((response) => {
    votes.value = response.map(vote => ({
      id: vote.id,
      creator: vote.creator,
      name: vote.name,
      rewardAmount: parseFloat(vote.rewardAmount),
      ended: vote.ended,
      winner: vote.winner,
      candidates: vote.candidates
    }));

  }).catch((err) => {
    console.log(err.message);
  });
};

const handleVoteError = (voteId, candidate, message) => {
  errorMessages.value.push(`Error in vote ${voteId} for candidate ${candidate}: ${message}`);
  alert(`Error in vote ${voteId} for candidate ${candidate}: ${message}`);
};


const listenToEvents = async () => {
  const instance = await VotingSystemContract.deployed();

  instance.VoteError({ fromBlock: 'latest' }, (error, event) => {
    if (error) {
      console.error('Error:', error);
      return;
    }
    const { voteId, candidate, message } = event.returnValues;
    console.error(`Error in vote ${voteId} for user ${candidate}: ${message}`);
    handleVoteError(voteId, candidate, message);
  });
};

loadPostedData();
listenToEvents();

/*************************** end votes *******************************/

/*************************** createVote相关 *******************************/
const postModalFlag = ref(false);
const post_vote = reactive({});
const init_post_vote = () => {
  post_vote.creator = '';
  post_vote.name = '';
  post_vote.rewardAmount = 1000000;
  post_vote.info = '';
};
init_post_vote();

const showPostModal = () => {
  post_vote.id = Date.now();
  postModalFlag.value = true;
};

const postSubmit = () => {
  VotingSystemContract.deployed().then(async (instance) => {
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];
    let res = instance.createVote(post_vote.name, post_vote.rewardAmount, { from: account, value: post_vote.rewardAmount * 1e12});
    console.log(post_vote.name);
    console.log(res);
    return res;
  }).then((response) => {
    init_post_vote();
    loadPostedData();
    postModalFlag.value = false;
  }).catch((err) => {
    alert('error', err.message);
    console.log(err.message);
  });
};
/*************************** end post *******************************/

/*************************** joinVote相关 *******************************/
const joinVote = (id) => {
  VotingSystemContract.deployed().then(async (instance) => {
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];
    return instance.joinVote(id, { from: account, value: 500000 * 1e12 });
  }).then((response) => {
    loadPostedData();
  }).catch((err) => {
    alert('error', err.message);
    console.log(err.message);
  });
};
/*************************** end joinVote *******************************/


/*************************** Voting for candidates **********************/
const castVote = (id, candidate) => {
  VotingSystemContract.deployed().then(async (instance) => {
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];
    await instance.vote(id, candidate, { from: account });
    loadPostedData();

    const hashedVote = hashVote(`${id}-${candidate}-${account}`);
    votesData.value.push(hashedVote);

    const tree = buildMerkleTree(votesData.value);
    merkleTree.value = tree.flat();
    merkleRoot.value = tree[tree.length - 1][0];

    const voteIndex = votesData.value.indexOf(hashedVote);
    const proofPath = generateMerkleProof(voteIndex, votesData.value);
    merkleProof.value = {
      leaf: hashedVote,
      path: proofPath,
      merkleRoot: merkleRoot.value,
    };
  

  }).catch((err) => {
    alert('error', err.message);
    console.log(err.message);
  });
};
/*************************** end voting *********************************/
</script>

<style scoped>
.carousel-container {
  margin: 0 10%;
  padding: 1% 1%;
  background-color: honeydew;
  border-radius: 15px;
}

.carousel {
  width: 100%;
  border-radius: 15px;
}

.carousel-img {
  margin: 0 auto;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.post-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.post-button {
  padding: 30px;
}

.modal {
  width: 600px;
}

.form {
  width: 600px;
}

.content-container {
  position: relative;
  min-height: 70vh; 
  margin-top: 5vh;
  padding: 2% 10%; 
  background-color: white;
  border-radius: 15px;
}

.merkle-tree-container {
  margin-top: 20px;
}

.proof-container {
  margin-top: 20px;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  margin: 10px 0;
}

</style>