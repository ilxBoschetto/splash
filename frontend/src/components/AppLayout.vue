<template>
    <div class="app-container">
        <!-- Topbar -->
        <Menubar :model="menuItems" />

        <!-- Contenuto principale -->
        <div class="app-content">
            <div class="main-card">
                <!-- Router view per i figli -->
                <router-view />
            </div>
        </div>
    </div>
</template>

<script setup>
import Menubar from 'primevue/menubar'
import { useRouter } from 'vue-router'

const router = useRouter()

const menuItems = [
    { label: 'Home', icon: 'pi pi-home', command: () => router.push('/') },
    { label: 'Fontanelle', icon: 'pi pi-map-marker', command: () => router.push('/fontanelle') },
    { label: 'Utenti', icon: 'pi pi-users', command: () => router.push('/utenti') },
]
</script>

<style scoped>
.app-container {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    background-color: var(--surface-ground);
}

.app-content {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    padding: 2rem;
}

.main-card {
    width: 100%;
    background-color: var(--surface-card);
    padding: 2rem;
    border-radius: 0.5rem;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
</style>
