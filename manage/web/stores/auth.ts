// stores/auth.ts
import { defineStore } from 'pinia'
import type { AdminUser, LoginParams } from '~/types/auth'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as AdminUser | null,
    token: null as string | null,
    isAuthenticated: false,
    loading: false,
  }),

  getters: {
    isSuperAdmin: (state) => state.user?.role === 'super_admin',
    hasPermission: (state) => (permission: string) => {
      if (state.user?.role === 'super_admin') return true
      return state.user?.permissions?.includes(permission) ?? false
    },
  },

  actions: {
    async login(params: LoginParams) {
      this.loading = true
      try {
        const { data } = await useFetch('/api/admin/auth/login', {
          method: 'POST',
          body: params,
        })
        
        if (data.value) {
          this.token = (data.value as any).access_token
          this.user = (data.value as any).user
          this.isAuthenticated = true
          
          // Save to localStorage
          if (process.client) {
            localStorage.setItem('admin_token', this.token!)
            localStorage.setItem('admin_user', JSON.stringify(this.user))
          }
        }
      } catch (error) {
        console.error('Login failed:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    logout() {
      this.user = null
      this.token = null
      this.isAuthenticated = false
      
      if (process.client) {
        localStorage.removeItem('admin_token')
        localStorage.removeItem('admin_user')
      }
      
      navigateTo('/login')
    },

    async initAuth() {
      if (process.client) {
        const token = localStorage.getItem('admin_token')
        const userStr = localStorage.getItem('admin_user')
        
        if (token && userStr) {
          this.token = token
          this.user = JSON.parse(userStr)
          this.isAuthenticated = true
        }
      }
    },
  },
})
