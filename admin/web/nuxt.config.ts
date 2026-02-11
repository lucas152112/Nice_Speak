// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
    '@nuxtjs/i18n',
  ],

  css: [
    'element-plus/dist/index.css',
    '~/assets/css/main.css',
  ],

  build: {
    transpile: ['element-plus/es', 'echarts'],
  },

  vite: {
    optimizeDeps: {
      include: ['echarts', 'vue-echarts'],
    },
  },

  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE || '/api/admin',
    },
  },

  i18n: {
    locales: [
      { code: 'zh_TW', name: '繁體中文', file: 'zh_TW.json' },
      { code: 'en', name: 'English', file: 'en.json' },
    ],
    lazy: true,
    langDir: 'locales/',
    defaultLocale: 'zh_TW',
    strategy: 'no_prefix',
  },

  app: {
    head: {
      title: 'Nice Speak Admin',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      ],
    },
  },

  compatibilityDate: '2024-01-01',
})
