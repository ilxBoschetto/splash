import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './assets/main.css'

import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap'

import axios from 'axios'

const app = createApp(App)

app.config.globalProperties.$axios = axios

app.use(router).mount('#app')