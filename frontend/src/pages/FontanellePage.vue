<template>
  <div class="p-4">
    <h2 class="text-xl font-semibold mb-4">Fontanelle</h2>

    <!-- Skeleton Loading -->
    <div v-if="isLoading" class="space-y-2">
      <Skeleton v-for="i in 5" :key="i" width="100%" height="10rem" />
    </div>

    <!-- Data Table -->
    <DataTable v-else :value="fontanelle" dataKey="id" stripedRows paginator :rows="20"
      class="shadow-sm rounded-xl overflow-hidden">
      <Column field="name" header="Nome" sortable />
      <Column field="lat" header="Latitudine" />
      <Column field="lon" header="Longitudine" />
      <Column header="Creato Da" :body="(row) => row.createdBy?.name || '—'" />
    </DataTable>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

// PrimeVue components
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Skeleton from 'primevue/skeleton'

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL

const fontanelle = ref([])
const isLoading = ref(true)

const getFontanelle = async () => {
  try {
    const { data } = await axios.get(`${apiBaseUrl}/fontanelle`)
    fontanelle.value = data
  } catch (error) {
    console.error('Errore API:', error)
  } finally {
    isLoading.value = false
  }
}

onMounted(getFontanelle)
</script>

<style scoped>
h2 {
  color: var(--text-color);
}

:deep(.p-datatable) {
  border-radius: 0.75rem;
  overflow: hidden;
}
</style>
