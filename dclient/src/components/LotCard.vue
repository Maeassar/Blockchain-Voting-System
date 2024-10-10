<template>
    <n-card hoverable embedded size="small">
        <template #cover>
            <img src="https://tse3-mm.cn.bing.net/th/id/OIP-C.nfC2tVNM9TgwQ5QuqECd6wHaFj?pid=ImgDet&rs=1">
        </template>
        <div class="title-container">
            <div class="title">{{ props.name }}</div>
        </div>
        <div class="info">
            <div class="bidder">{{ props.currentBidder }}</div>
            <div>￥{{ props.currentPrice }}</div>
        </div>
    </n-card>
</template>

<script setup>
import { NCard } from 'naive-ui';
// import { CurrencyYuanFilled as Yuan } from '@vicons/material'

const props = defineProps({
    name: String,
    info: String,
    currentBidder: String,
    currentPrice: Number,
    endTimestamp: Number,
    img: String,
})

</script>

<style scoped>
.n-card {
    width: 100%;
}

img {
    width: 100;
    object-fit: cover;
}

.title-container {
    border-radius: 10px;
    position: relative;
    bottom: 30px;
    overflow: hidden;
    text-align: center;
    display: flex;
    justify-content: left;
    align-items: center;
}

.title {
    width: fit-content;
    padding: 0 10%;
    background-color: rgba(255, 255, 255, 0.7);
    border-radius: 10px;
    font-size: large;
    color: black;
}

.info {
    position: relative;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    align-items: center;
    font-size: larger;
    bottom: 5px;
}

.bidder {
    width: 100%;
    word-wrap: break-word;
}
</style>