// services/menu.ts
import type { MenuItem, MenuNode, CreateMenuParams, UpdateMenuParams, ReorderMenuParams } from '~/types/auth'

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

// 樹狀菜單
export async function getMenusTree(): Promise<{
  menus: MenuNode[]
}> {
  return fetchApi('/menus/tree')
}

// 菜單列表 (扁平)
export async function getMenus(): Promise<{
  menus: MenuItem[]
  total: number
}> {
  return fetchApi('/menus')
}

// 菜單詳情
export async function getMenu(id: string): Promise<MenuItem> {
  return fetchApi(`/menus/${id}`)
}

// 建立菜單
export async function createMenu(data: CreateMenuParams): Promise<{
  success: boolean
  menu: { id: string; name: string; path: string; order: number }
}> {
  return fetchApi('/menus', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}

// 更新菜單
export async function updateMenu(id: string, data: UpdateMenuParams): Promise<{
  success: boolean
  message: string
}> {
  return fetchApi(`/menus/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}

// 刪除菜單
export async function deleteMenu(id: string): Promise<{
  success: boolean
  message: string
}> {
  return fetchApi(`/menus/${id}`, {
    method: 'DELETE',
  })
}

// 調整順序
export async function reorderMenus(data: ReorderMenuParams): Promise<{
  success: boolean
  message: string
}> {
  return fetchApi('/menus/reorder', {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}
