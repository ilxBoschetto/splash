<template>
  <div>
    <h2>Utenti</h2>
    <div v-if="isLoading" class="skeleton-table">
    </div>
    <table v-else class="table table-custom">
      <thead>
        <tr>
          <th>Nome</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="f.id">
          <td>{{ user.name }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL

const users = ref([])
const isLoading = ref(true);
const getUsers = () => {
  axios.get(`${apiBaseUrl}/users`, {})
    .then((response) => {
      users.value = response.data;
    })
    .catch(error => {
      console.error('Errore API:', error)
    })
}
onMounted(() => {
  Promise.all([
    getUsers()
  ]).finally(() => {
    isLoading.value = false;
  });
})

</script>