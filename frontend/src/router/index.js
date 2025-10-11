import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../pages/HomePage.vue'
import UtentiPage from '../pages/UtentiPage.vue'
import FontanellePage from '../pages/FontanellePage.vue'

const routes = [
  { path: '/', component: HomePage },
  { path: '/utenti', component: UtentiPage },
  { path: '/fontanelle', component: FontanellePage },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
