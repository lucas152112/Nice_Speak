// types/auth.ts

export interface AdminUser {
  id: string
  email: string
  name: string
  role_id: string
  role_code?: string
  role_name?: string
  permissions: string[]
  avatar?: string
  status: boolean
}

export interface LoginParams {
  email: string
  password: string
}

export interface LoginResponse {
  access_token: string
  user: AdminUser
}

// 權限相關類型
export interface Permission {
  id: string
  code: string
  name: string
  module: string
  type: string
  description?: string
  status: boolean
}

export interface PermissionGroup {
  module: string
  display_name: string
  permissions: Permission[]
}

// 角色相關類型
export interface Role {
  id: string
  code: string
  name: string
  description?: string
  is_system: boolean
  level: number
  status: boolean
  created_at: string
  updated_at: string
}

export interface RoleDetail extends Role {
  permissions: Permission[]
}

export interface RoleQuery {
  page?: number
  limit?: number
  keyword?: string
}

export interface Pagination {
  page: number
  limit: number
  total: number
  total_pages: number
}

// 菜單相關類型
export interface MenuItem {
  id: string
  name: string
  icon?: string
  path?: string
  parent_id?: string
  order: number
  status: boolean
  children?: MenuNode[]
}

export interface MenuNode extends MenuItem {
  children: MenuNode[]
}

export interface CreateRoleParams {
  code: string
  name: string
  description?: string
  level: number
  permissions?: string[]
}

export interface UpdateRoleParams {
  name: string
  description?: string
  level: number
  permissions?: string[]
}

export interface UpdateRolePermissionsParams {
  permissions: string[]
}

export interface UpdateRoleMenusParams {
  menus: string[]
}

export interface CreateMenuParams {
  name: string
  icon?: string
  path?: string
  parent_id?: string
  order: number
}

export interface UpdateMenuParams {
  name: string
  icon?: string
  path?: string
  parent_id?: string
  order: number
}

export interface ReorderMenuParams {
  orders: Array<{ id: string; order: number }>
}
