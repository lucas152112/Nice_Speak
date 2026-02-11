<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<script setup lang="ts">
useHead({
  titleTemplate: (title) => title ? `${title} - Nice Speak 管理後台` : 'Nice Speak 管理後台',
  meta: [
    { name: 'description', content: 'Nice Speak 管理後台' }
  ]
})
</script>
