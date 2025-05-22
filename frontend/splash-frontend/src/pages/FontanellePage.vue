<template>
  <div>
    <h2>Fontanelle</h2>
    <div v-if="isLoading" class="skeleton-table">
    </div>
    <table v-else class="table table-custom">
      <thead>
        <tr>
          <th>Nome</th>
          <th>Latitudine</th>
          <th>Longitudine</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="f in fontanelle" :key="f.id">
          <td>{{ f.name }}</td>
          <td>{{ f.lat }}</td>
          <td>{{ f.lon }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL

const fontanelle = ref([])
const isLoading = ref(true);

const getFontanelle = () => {
  axios.get(`${apiBaseUrl}/fontanelle`, {})
    .then((response) => {
      console.log(response.data)
      fontanelle.value = response.data;
    })
    .catch(error => {
      console.error('Errore API:', error)
    })
}

onMounted(() => {
  Promise.all([
    getFontanelle()
  ]).finally(() => {
    isLoading.value = false;
  });
})
</script>
<style scoped>
.table-custom {
  background-color: var(--custom-surface);
  color: var(--custom-text);
  border: 1px solid var(--custom-border);
}

.table-custom th {
  background-color: var(--custom-surface);
  color: var(--custom-text);
  border: 1px solid var(--custom-border);
}

.table-custom td {
  background-color: var(--custom-bg);
  color: var(--custom-text);
  border: 1px solid var(--custom-border);
}

.skeleton-table {
  width: 100%;
  height: 40rem;
  border-radius: 0.8rem;
  background-color: var(--custom-skeleton-base);
  animation: pulse 1.5s infinite ease-in-out;
}

@keyframes pulse {
  0% {
    opacity: 0.3;
  }

  50% {
    opacity: 1;
  }

  100% {
    opacity: 0.3;
  }
}
</style>