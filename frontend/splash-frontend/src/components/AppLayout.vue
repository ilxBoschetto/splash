<template>
  <div>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
      <div class="container">
        <a class="navbar-brand" href="#">FontanelleApp</a>
        <div class="collapse navbar-collapse">
          <ul class="navbar-nav me-auto mb-2 mb-lg-0">
            <li class="nav-item">
              <RouterLink class="nav-link" to="/">Home</RouterLink>
            </li>
            <li class="nav-item">
              <RouterLink class="nav-link" to="/fontanelle">Fontanelle</RouterLink>
            </li>
            <li class="nav-item">
              <RouterLink class="nav-link" to="/utenti">Utenti</RouterLink>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <main class="container mt-4">
      <RouterView />
    </main>
  </div>
</template>

<script setup>
</script>
