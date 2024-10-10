import { createRouter, createWebHashHistory } from 'vue-router'
// import IndexVue from '@/views/Index.vue'
import VotingSystemVue from '@/views/VotingSystem.vue'
// import AuctionVue from '@/views/Auction.vue'

// 路由规则
const routes = [
    {
        path: '/',
        name: 'defalut',
        component: VotingSystemVue
    },
    {
        path: '/votingsystem',
        name: 'votingsystem',
        component: VotingSystemVue
    },
]

// 路由实例
export default createRouter({
    history: createWebHashHistory(),
    routes,
})