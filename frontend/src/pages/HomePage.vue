<template>
  <div class="flex flex-column align-items-center justify-content-center gap-4 p-5">
    <!-- Titolo -->
    <h2 class="text-3xl font-bold text-primary">Benvenuto in Splash</h2>

    <!-- Card introduttiva -->
    <Card class="w-full md:w-8 shadow-2 border-round-lg text-center">
      <template #title>
        <div class="flex align-items-center justify-content-center gap-2">
          <i class="pi pi-home text-primary text-2xl"></i>
          <span>Home Page</span>
        </div>
      </template>

      <template #content>
        <p class="text-700 text-lg mb-4">
          Questa è la pagina iniziale della tua applicazione.
          Da qui puoi accedere alle sezioni <strong>Fontanelle</strong> e <strong>Utenti</strong>
          tramite il menu laterale.
        </p>

        <Divider />

        <Message severity="info" class="w-full md:w-6 mx-auto">
          Suggerimento: puoi personalizzare i colori e i temi PrimeVue dal tuo <code>.env</code> o dai CSS globali.
        </Message>

        <div class="mt-4">
          <Button label="Vai alle Fontanelle" icon="pi pi-map-marker" class="p-button-primary mr-2"
            @click="$router.push('/fontanelle')" />
          <Button label="Gestisci Utenti" icon="pi pi-users" class="p-button-secondary"
            @click="$router.push('/utenti')" />
        </div>
      </template>
    </Card>
  </div>
</template>

<script setup>
import Card from 'primevue/card'
import Divider from 'primevue/divider'
import Button from 'primevue/button'
import Message from 'primevue/message'
</script>
