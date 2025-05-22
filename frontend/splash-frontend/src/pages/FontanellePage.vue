<template>
  <div>
    <h2>Fontanelle</h2>
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>Nome</th>
          <th>Latitudine</th>
          <th>Longitudine</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="f in fontanelle" :key="f.id">
          <td>{{ f.nome }}</td>
          <td>{{ f.lat }}</td>
          <td>{{ f.lon }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const fontanelle = ref([
  { id: 1, nome: 'Fontanella A', lat: 45.12, lon: 9.45 },
  { id: 2, nome: 'Fontanella B', lat: 45.78, lon: 9.10 },
])
</script>
