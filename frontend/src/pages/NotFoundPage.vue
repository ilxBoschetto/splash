<template>
    <div class="flex flex-column align-items-center justify-content-center h-full text-center p-6">
        <i class="pi pi-exclamation-triangle text-5xl text-orange-500 mb-3"></i>
        <h2 class="text-2xl mb-2">Pagina non trovata</h2>
        <p class="text-600 mb-4">La pagina che stai cercando non esiste o è stata spostata.</p>
        <Button label="Torna alla Home" icon="pi pi-home" @click="$router.push('/')" />
    </div>
</template>

<script setup>
import { Button } from 'primevue/button'
</script>
