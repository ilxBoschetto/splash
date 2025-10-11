import { createRouter, createWebHistory } from 'vue-router'

// Lazy load pagine
const HomePage = () => import('@/pages/HomePage.vue')
const UtentiPage = () => import('@/pages/UtentiPage.vue')
const FontanellePage = () => import('@/pages/FontanellePage.vue')
const LoginPage = () => import('@/pages/LoginPage.vue')
const NotFoundPage = () => import('@/pages/NotFoundPage.vue')

const routes = [
  {
    path: '/',
    component: () => import('@/components/AppLayout.vue'),
    children: [
      { path: '', name: 'home', component: HomePage, meta: { title: 'Home | Splash' } },
      { path: 'utenti', name: 'utenti', component: UtentiPage, meta: { title: 'Utenti | Splash' } },
      { path: 'fontanelle', name: 'fontanelle', component: FontanellePage, meta: { title: 'Fontanelle | Splash' } },
    ]
  },
  {
    path: '/auth/login',
    name: 'login',
    component: LoginPage,
    meta: { title: 'Login | Splash' }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: NotFoundPage,
    meta: { title: 'Pagina non trovata | Splash' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Aggiorna titolo dinamicamente
router.beforeEach((to, _, next) => {
  document.title = to.meta.title || 'Splash'
  next()
})

export default router
