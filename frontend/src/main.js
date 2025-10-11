import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import axios from 'axios'

// 🔹 PrimeVue base + tema Arya Blue
import 'primevue/resources/primevue.min.css'
import 'primevue/resources/themes/arya-blue/theme.css'
import 'primeicons/primeicons.css'

import PrimeVue from 'primevue/config'
import Button from 'primevue/button'
import Menubar from 'primevue/menubar'

const app = createApp(App)

// Config globale axios
app.config.globalProperties.$axios = axios

// PrimeVue e componenti globali
app.use(PrimeVue)
app.component('Button', Button)
app.component('Menubar', Menubar)

// Router
app.use(router)

app.mount('#app')
