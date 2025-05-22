<template>
    <div class="d-flex flex-column min-vh-100">
        <div class="d-flex flex-grow-1">
            <!-- Sidebar -->
            <nav class="sidebar p-3">
                <div class="">
                    <span class="main-title">Splash</span>
                    <img :src="icon" class="icon" alt="Icon" />
                </div>
                
                <hr>
                <ul class="nav flex-column">
                    <li class="nav-item mb-2" v-for="(item, index) in menuItems" :key="item.to">
                        <RouterLink
                            class="nav-link"
                            :class="{ active: route?.path === item.to }"
                            :to="item.to"
                        >
                            {{ item.label }}
                        </RouterLink>
                        <hr v-if="index !== menuItems.length - 1" class="my-1 mx-4" style="border-color: var(--custom-text-alt)" />
                    </li>
                </ul>
            </nav>

            <!-- Main content -->
            <main class="flex-grow-1 p-4">
                <RouterView />
            </main>
        </div>

        <!-- Footer -->
        <footer class="footer text-end py-2 px-1">
            <small>© 2025 Splash - Matteo Boschetti</small>
        </footer>
    </div>
</template>

<script setup>
import { useRoute } from 'vue-router';
import icon from '@/assets/images/icon.png';

const route = useRoute();

const menuItems = [
    { to: '/', label: 'Home' },
    { to: '/fontanelle', label: 'Fontanelle' },
    { to: '/utenti', label: 'Utenti' }
];
</script>

<style scoped>
.sidebar {
    min-width: 15rem;
    background-color: var(--custom-primary);
    color: var(--custom-text);
}

.nav-link {
    color: var(--custom-text-alt);
    padding: 0.5rem 1rem;
    display: block;
    border-radius: 0.2rem;
    text-decoration: none;
}

.nav-link:hover {
    color: var(--custom-text-alt);
}

.nav-link.active {
    color: var(--custom-text-alt);
    font-size: 1.15rem;
    background-color: var(--custom-primary);
    font-weight: bold;
    border-left: 0.1rem solid var(--custom-text-alt);
}

.main-content {
    background-color: var(--custom-bg);
    color: var(--custom-text);
}

.main-title {
    color: var(--custom-text-alt);
    font-size: 2rem;
}

.footer {
    background-color: var(--custom-secondary);
    color: var(--custom-text);
}
.icon {
    height: 5rem;
}
</style>
