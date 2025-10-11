<template>
    <div class="flex justify-content-center align-items-center min-h-screen bg-gray-50">
        <Card class="shadow-2 w-25rem">
            <template #title>
                <div class="text-center text-2xl font-bold text-primary">Accedi a Splash</div>
            </template>

            <template #content>
                <form @submit.prevent="login" class="flex flex-column gap-3 mt-3">
                    <div>
                        <label for="email" class="block mb-2 font-medium">Email</label>
                        <InputText id="email" v-model="email" type="email" placeholder="Inserisci la tua email"
                            class="w-full" required />
                    </div>

                    <div>
                        <label for="password" class="block mb-2 font-medium">Password</label>
                        <Password id="password" v-model="password" toggleMask feedback="false"
                            placeholder="Inserisci la tua password" class="w-full" inputClass="w-full" required />
                    </div>

                    <Button label="Login" icon="pi pi-sign-in" class="w-full mt-3" type="submit" />
                </form>

                <Message v-if="errorMessage" severity="error" :text="errorMessage" class="mt-3" />
            </template>
        </Card>
    </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

// PrimeVue components
import Card from 'primevue/card'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Button from 'primevue/button'
import Message from 'primevue/message'

const router = useRouter()

const email = ref('')
const password = ref('')
const errorMessage = ref('')

const login = async () => {
    try {
        // TODO: chiamata API login reale
        if (email.value === 'test@splash.it' && password.value === '1234') {
            router.push('/')
        } else {
            errorMessage.value = 'Credenziali non valide'
        }
    } catch (err) {
        errorMessage.value = 'Errore durante il login'
    }
}
</script>