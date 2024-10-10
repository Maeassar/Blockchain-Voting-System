<template>
    <n-card hoverable embedded size="large">
        <template #cover>
            <img src="@/assets/img/demo.jpeg">
        </template>
        <div class="title-container">
            <div class="title">{{ props.title }}</div>
        </div>
        <div class="info">
            <div class="info-item">
                <span>Creator:</span>
                <span>{{ author }}</span>
            </div>
            <div class="info-item">
                <span>Ended:</span>
                <span>{{ ended }}</span>
            </div>
            <div class="info-item">
                <span>Winner:</span>
                <span>{{ winner }}</span>
            </div>
        </div>

        <div class="button-container">
            <n-button @click="$emit('joinVote', id)" type="primary" size="large"  class="join-button">Join Vote</n-button>
            <div v-for="candidate in candidates" :key="candidate" class="candidate-button">
                <span>Vote for Candidate: </span>
                <n-button @click="$emit('vote', id, candidate)" size="middle" class="vote-button">{{ candidate }}</n-button>
            </div>
        </div>
    </n-card>
</template>

<script setup>
import { NCard } from 'naive-ui';
// import { CurrencyYuanFilled as Yuan } from '@vicons/material'

const props = defineProps({
    title: String,
    author: String,
    price: Number,
    img: String,
    id: String,
    candidates: Array,
    ended: Boolean,
    winner: String
})

</script>

<style scoped>
.n-card {
  width: 100%;
  padding: 20px; /* 增加卡片内边距 */
}

img {
  width: 100%;
  height: 200px; /* 增加图片高度 */
  object-fit: cover;
}

.title-container {
  border-radius: 10px;
  margin-top: 10px;
  overflow: hidden;
  text-align: center;
  display: flex;
  justify-content: center; /* 调整标题居中 */
  align-items: center;
}

.title {
  width: fit-content;
  padding: 10px 20px; /* 增加标题内边距 */
  background-color: rgba(255, 255, 255, 0.7);
  border-radius: 10px;
  font-size: larger; 
  color: black;
}

.info {
    /*margin-top: 10px;*/
    display: flex;
    flex-direction: column; 
    align-items: left;
    font-size: larger;
}

.info-item {
    display: flex;
    justify-content: space-between; 
    width: 100%; 
}


.button-container {
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  align-items: center;
}

.candidate-button {
  display: inline-block; 
  margin-right: 10px; 
}

.join-button, .vote-button {
    width: 100%; 
    padding: 8px 10px; 
    border-radius: 10px;
    background-color: rgb(151, 199, 151);
    color: black;
    font-size: medium; 
    margin-bottom: 20px; 
    text-align: center; 
}

</style>