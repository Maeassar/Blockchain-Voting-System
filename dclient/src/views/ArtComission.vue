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
                Post
            </n-button>

            <n-modal v-model:show="postModalFlag" :style="{ width: '600px' }" preset="card" size="huge"
                :bordered="false">
                <n-form ref="formRef" :model="post_comission" label-placement="left" label-width="auto"
                    require-mark-placement="right-hanging">
                    <n-form-item label="作者" path="inputValue">
                        <n-input v-model:value="post_comission.author" placeholder="Author" />
                    </n-form-item>
                    <n-form-item label="主题" path="inputValue">
                        <n-input v-model:value="post_comission.title" placeholder="Title" />
                    </n-form-item>
                    <n-form-item label="价格" path="inputNumberValue">
                        <n-input-number v-model:value="post_comission.price" placeholder="Price" />
                        <div>&nbsp;&nbsp; × 1e12 Wei(ETH-6)</div>
                    </n-form-item>
                    <n-form-item label="详情" path="textareaValue">
                        <n-input v-model:value="post_comission.info" placeholder="Info" type="textarea" :autosize="{
                            minRows: 3,
                            maxRows: 5
                        }" />
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
            <n-grid :x-gap="12" :y-gap="8" :cols="4">
                <n-gi v-for="comission in comissions" :key="comission.id">
                    <CardVue :title="comission.title" :author="comission.author" :price="comission.price"
                        :img="comission.img" @click="purchase(comission.id, comission.price)"></CardVue>
                </n-gi>
            </n-grid>
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


// 初始化合约以及连接MetaMask
const contract = require('@truffle/contract')
const artifact = require('../assets/contracts/ArtComission.json')
const ArtComissionContract = contract(artifact);
ArtComissionContract.setProvider(window.ethereum)


/*************************** comissions相关 *******************************/
// 获得comissions并在页面中显示
const comissions = ref([])
const loadPostedData = () => {
    ArtComissionContract.deployed().then((instance) => {
        let res = instance.get_selected_comissions.call(false)
        return res
    }).then((response) => {
        comissions.value.length = 0
        for (let i = 0; i < response.length; i++) {
            let comission = response[i]
            comissions.value.push({
                id: comission.id,
                author: comission.author,
                title: comission.title,
                price: parseFloat(comission.price),
                info: comission.info,
                img: '../assets/logo.png',
            })
        }
    }).catch((err) => {
        console.log(err.message);
    });
}
loadPostedData()
/*************************** end comissions *******************************/


/*************************** post相关 *******************************/
const postModalFlag = ref(false)
const post_comission = reactive({})
const init_post_comission = () => {
    post_comission.author = '',
        post_comission.title = '',
        post_comission.price = 1000000,
        post_comission.info = ''
}
init_post_comission()

const showPostModal = () => {
    // 这里追求方便以时间戳为id，后续可改成别的API获取唯一id
    post_comission.id = Date.now()
    postModalFlag.value = true
}

const postSubmit = () => {
    ArtComissionContract.deployed().then(async (instance) => {
        const accounts = await ethereum.request({ method: 'eth_requestAccounts' })
        const account = await accounts[0]
        console.log("post_comission")
        let res = instance.post(
            post_comission.id, post_comission.author, post_comission.title,
            post_comission.price, post_comission.info, { from: account }
        )
        console.log(res)
        return res
    }).then((response) => {
        init_post_comission()
        loadPostedData()
        postModalFlag.value = false
    }).catch((err) => {
        alert('error', err.message)
        console.log(err.message);
    });
}
/*************************** end post *******************************/


/*************************** purchase相关 *******************************/
const purchase = (id, price) => {
    ArtComissionContract.deployed().then(async (instance) => {
        const accounts = await ethereum.request({ method: 'eth_requestAccounts' })
        const account = await accounts[0]
        return instance.purchase(id, { from: account, value: (price * 1e12) })
    }).then((response) => {
        loadPostedData()
    }).catch((err) => {
        alert('error', err.message)
        console.log(err.message);
    });
}
/*************************** end purchase *******************************/

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

.post-container {}

.post-button {
    position: fixed;
    padding: 30px;
    right: 40px;
    bottom: 40px;
    z-index: 1;
}

.modal {
    width: 600px;
}

.form {
    width: 600px;
}

.content-container {
    position: relative;
    min-height: 50vh;
    margin-top: 5vh;
    padding: 1% 5%;
    background-color: white;
    border-radius: 15px;
}
</style>


