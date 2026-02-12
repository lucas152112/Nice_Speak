#!/bin/bash
# =====================================================
# RBAC API 整合測試腳本
# Integration Test Script
# =====================================================
# Usage: ./test_api.sh [base_url]
# Default base_url: http://localhost:8080
# =====================================================

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 變數
BASE_URL="${1:-http://localhost:8080}"
TOKEN=""
PASS_COUNT=0
FAIL_COUNT=0

# 輸出樣式
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASS_COUNT++))
}

print_fail() {
    echo -e "${RED}✗ $1${NC}"
    ((FAIL_COUNT++))
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# 登入取得 Token
login() {
    print_header "1. 認證測試"
    
    # 測試登入
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"admin@nicespeak.app","password":"admin123"}')
    
    if echo "$RESPONSE" | grep -q "access_token"; then
        TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
        print_success "登入成功 - Token: ${TOKEN:0:20}..."
    else
        print_fail "登入失敗: $RESPONSE"
    fi
}

# 測試角色 API
test_roles() {
    print_header "2. 角色管理 API 測試"
    
    # 取得角色列表
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "roles"; then
        print_success "GET /api/admin/roles - 取得角色列表"
    else
        print_fail "GET /api/admin/roles - $RESPONSE"
    fi
    
    # 測試分頁
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles?page=1&limit=10" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "pagination"; then
        print_success "GET /api/admin/roles?page=1&limit=10 - 分頁功能"
    else
        print_fail "分頁測試失敗"
    fi
    
    # 測試關鍵字搜尋
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles?keyword=admin" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "roles"; then
        print_success "GET /api/admin/roles?keyword=admin - 搜尋功能"
    else
        print_fail "搜尋測試失敗"
    fi
}

# 測試權限 API
test_permissions() {
    print_header "3. 權限管理 API 測試"
    
    # 取得權限列表
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/permissions" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "permissions"; then
        print_success "GET /api/admin/permissions - 取得權限列表"
    else
        print_fail "GET /api/admin/permissions - $RESPONSE"
    fi
    
    # 取得分組權限
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/permissions/grouped" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "groups"; then
        print_success "GET /api/admin/permissions/grouped - 取得分組權限"
    else
        print_fail "分組權限測試失敗"
    fi
}

# 測試菜單 API
test_menus() {
    print_header "4. 菜單管理 API 測試"
    
    # 取得樹狀菜單
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/menus/tree" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "menus"; then
        print_success "GET /api/admin/menus/tree - 取得樹狀菜單"
    else
        print_fail "GET /api/admin/menus/tree - $RESPONSE"
    fi
    
    # 取得扁平菜單列表
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/menus" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "menus"; then
        print_success "GET /api/admin/menus - 取得菜單列表"
    else
        print_fail "菜單列表測試失敗"
    fi
}

# 測試錯誤處理
test_errors() {
    print_header "5. 錯誤處理測試"
    
    # 測試無 Token 訪問
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles")
    
    if echo "$RESPONSE" | grep -q "Unauthorized\|未授權"; then
        print_success "無 Token 訪問 - 正確拒絕"
    else
        print_fail "無 Token 訪問應返回錯誤"
    fi
    
    # 測試錯誤 Token
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles" \
        -H "Authorization: Bearer invalid_token")
    
    if echo "$RESPONSE" | grep -q "error\|Unauthorized"; then
        print_success "錯誤 Token - 正確拒絕"
    else
        print_fail "錯誤 Token 處理異常"
    fi
    
    # 測試不存在的資源
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles/not-found-id" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "error\|Not Found"; then
        print_success "404 錯誤 - 正確處理"
    else
        print_fail "404 錯誤處理異常"
    fi
}

# 測試 CRUD 流程
test_crud() {
    print_header "6. CRUD 完整流程測試"
    
    # 建立新角色
    print_info "建立測試角色..."
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/roles" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"code":"test_role_001","name":"測試角色","description":"整合測試建立","level":10}')
    
    if echo "$RESPONSE" | grep -q "success"; then
        print_success "POST /api/admin/roles - 建立角色成功"
        ROLE_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    else
        print_fail "建立角色失敗: $RESPONSE"
        return
    fi
    
    # 更新角色
    print_info "更新角色..."
    RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/roles/$ROLE_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"name":"更新後的角色","level":20}')
    
    if echo "$RESPONSE" | grep -q "success"; then
        print_success "PUT /api/admin/roles/:id - 更新角色成功"
    else
        print_fail "更新角色失敗"
    fi
    
    # 取得角色詳情
    print_info "取得角色詳情..."
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles/$ROLE_ID" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "更新後的角色"; then
        print_success "GET /api/admin/roles/:id - 取得詳情成功"
    else
        print_fail "取得詳情失敗"
    fi
    
    # 刪除角色
    print_info "刪除角色..."
    RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/roles/$ROLE_ID" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "success"; then
        print_success "DELETE /api/admin/roles/:id - 刪除角色成功"
    else
        print_fail "刪除角色失敗"
    fi
}

# 測試角色關聯功能
test_relationships() {
    print_header "7. 關聯功能測試"
    
    # 取得角色權限
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles/role-001/permissions" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "permissions"; then
        print_success "GET /api/admin/roles/:id/permissions - 取得角色權限"
    else
        print_fail "取得角色權限失敗"
    fi
    
    # 取得角色菜單
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles/role-001/menus" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$RESPONSE" | grep -q "menus"; then
        print_success "GET /api/admin/roles/:id/menus - 取得角色菜單"
    else
        print_fail "取得角色菜單失敗"
    fi
}

# 輸出測試結果
print_result() {
    print_header "測試結果摘要"
    
    TOTAL=$((PASS_COUNT + FAIL_COUNT))
    
    echo -e "總測試數: ${TOTAL}"
    echo -e "${GREEN}通過: ${PASS_COUNT}${NC}"
    echo -e "${RED}失敗: ${FAIL_COUNT}${NC}"
    echo -e ""
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}🎉 所有測試通過！${NC}"
        exit 0
    else
        echo -e "${RED}❌ 有測試失敗，請檢查日誌${NC}"
        exit 1
    fi
}

# 主程式
main() {
    echo ""
    echo "=============================================="
    echo "   RBAC API 整合測試"
    echo "   Base URL: $BASE_URL"
    echo "=============================================="
    
    # 執行測試
    login
    test_roles
    test_permissions
    test_menus
    test_errors
    test_crud
    test_relationships
    
    # 輸出結果
    print_result
}

main "$@"
