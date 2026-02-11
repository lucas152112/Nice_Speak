// services/permission.ts
import type { Permission, PermissionGroup, PermissionQuery } from '~/types/auth'

const API_BASE = '/api/admin'

async function fetchApi<T>(
  url: string,
  options: RequestInit = {}
): Promise<T> {
  const token = process.client ? localStorage.getItem('admin_token') : null
  
  const response = await fetch(`${API_BASE}${url}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': token ? `Bearer ${token}` : '',
      ...options.headers,
    },
  })
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: 'Request failed' }))
    throw new Error(error.message || 'Request failed')
  }
  
  return response.json()
}

// 權限列表
export async function getPermissions(params: PermissionQuery = {}): Promise<{
  permissions: Permission[]
  total: number
}> {
  const query = new URLSearchParams()
  if (params.module) query.set('module', params.module)
  if (params.type) query.set('type', params.type)
  if (params.keyword) query.set('keyword', params.keyword)
  
  return fetchApi(`/permissions?${query.toString()}`)
}

// 分組權限
export async function getPermissionsGrouped(): Promise<{
  groups: PermissionGroup[]
  total: number
}> {
  return fetchApi('/permissions/grouped')
}

// 權限詳情
export async function getPermission(id: string): Promise<Permission> {
  return fetchApi(`/permissions/${id}`)
}
