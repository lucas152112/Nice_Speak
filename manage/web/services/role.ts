// services/role.ts
import type {
  Role,
  RoleDetail,
  RoleQuery,
  Pagination,
  CreateRoleParams,
  UpdateRoleParams,
  UpdateRolePermissionsParams,
  UpdateRoleMenusParams,
} from '~/types/auth'

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

// 角色列表
export async function getRoles(params: RoleQuery = {}): Promise<{
  roles: Role[]
  pagination: Pagination
}> {
  const query = new URLSearchParams()
  if (params.page) query.set('page', params.page.toString())
  if (params.limit) query.set('limit', params.limit.toString())
  if (params.keyword) query.set('keyword', params.keyword)
  
  return fetchApi(`/roles?${query.toString()}`)
}

// 角色詳情
export async function getRole(id: string): Promise<RoleDetail> {
  return fetchApi(`/roles/${id}`)
}

// 建立角色
export async function createRole(data: CreateRoleParams): Promise<{
  success: boolean
  role: { id: string; code: string; name: string }
}> {
  return fetchApi('/roles', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}

// 更新角色
export async function updateRole(id: string, data: UpdateRoleParams): Promise<{
  success: boolean
  message: string
}> {
  return fetchApi(`/roles/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}

// 刪除角色
export async function deleteRole(id: string): Promise<{
  success: boolean
  message: string
}> {
  return fetchApi(`/roles/${id}`, {
    method: 'DELETE',
  })
}

// 取得角色權限
export async function getRolePermissions(id: string): Promise<{
  permissions: any[]
  total: number
}> {
  return fetchApi(`/roles/${id}/permissions`)
}

// 更新角色權限
export async function updateRolePermissions(
  id: string,
  data: UpdateRolePermissionsParams
): Promise<{
  success: boolean
  message: string
}> {
  return fetchApi(`/roles/${id}/permissions`, {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}

// 取得角色菜單
export async function getRoleMenus(id: string): Promise<{
  menus: any[]
}> {
  return fetchApi(`/roles/${id}/menus`)
}

// 更新角色菜單
export async function updateRoleMenus(
  id: string,
  data: UpdateRoleMenusParams
): Promise<{
  success: boolean
  message: string
}> {
  return fetchApi(`/roles/${id}/menus`, {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}
