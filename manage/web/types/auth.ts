// types/auth.ts

export interface AdminUser {
  id: string
  email: string
  name: string
  role: string
  permissions: string[]
  avatar?: string
}

export interface LoginParams {
  email: string
  password: string
}

export interface LoginResponse {
  access_token: string
  user: AdminUser
}

export interface Permission {
  id: string
  name: string
  code: string
  description: string
}

export interface Role {
  id: string
  name: string
  code: string
  permissions: string[]
}
