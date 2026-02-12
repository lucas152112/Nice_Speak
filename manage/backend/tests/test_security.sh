# =====================================================
# 安全測試腳本
# Security Test Script
# =====================================================
# Usage: ./test_security.sh [base_url]
# =====================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

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

print_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((WARN_COUNT++))
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

BASE_URL="${1:-http://localhost:8080}"

# =====================================================
# 1. SQL 注入測試
# =====================================================
test_sql_injection() {
    print_header "1. SQL 注入測試"
    
    # 測試登入表單
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"admin@email.com","password":"'\'' OR '\''1'\''='\''1"}')
    
    if echo "$RESPONSE" | grep -qi "error\|invalid\|Unauthorized"; then
        print_success "SQL 注入測試 (登入): 正確拒絕"
    else
        print_fail "SQL 注入測試 (登入): 可能存在漏洞"
    fi
    
    # 測試角色查詢
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles?keyword=' OR 1=1" \
        -H "Authorization: Bearer invalid")
    
    if echo "$RESPONSE" | grep -qi "error\|invalid"; then
        print_success "SQL 注入測試 (查詢): 正確拒絕"
    else
        print_fail "SQL 注入測試 (查詢): 可能存在漏洞"
    fi
    
    # 測試 ID 參數
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles/' OR 1=1--" \
        -H "Authorization: Bearer invalid")
    
    if echo "$RESPONSE" | grep -qi "error\|not found"; then
        print_success "SQL 注入測試 (ID): 正確處理"
    else
        print_fail "SQL 注入測試 (ID): 可能存在漏洞"
    fi
}

# =====================================================
# 2. XSS 攻擊測試
# =====================================================
test_xss() {
    print_header "2. XSS 攻擊測試"
    
    # 測試腳本標籤
    XSS_PAYLOAD='<script>alert("XSS")</script>'
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/roles" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer invalid" \
        -d "{\"code\":\"test\",\"name\":\"$XSS_PAYLOAD\",\"level\":1}")
    
    if echo "$RESPONSE" | grep -qi "error\|invalid"; then
        print_success "XSS 測試 (script): 正確拒絕"
    else
        print_fail "XSS 測試 (script): 可能存在漏洞"
    fi
    
    # 測試 img onerror
    XSS_PAYLOAD='<img src=x onerror=alert(1)>'
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles?keyword=$XSS_PAYLOAD" \
        -H "Authorization: Bearer invalid")
    
    if echo "$RESPONSE" | grep -qi "error\|invalid"; then
        print_success "XSS 測試 (img): 正確拒絕"
    else
        print_fail "XSS 測試 (img): 可能存在漏洞"
    fi
    
    # 測試 SVG
    XSS_PAYLOAD='<svg onload=alert(1)>'
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/roles" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer invalid" \
        -d "{\"code\":\"test2\",\"name\":\"$XSS_PAYLOAD\",\"level\":1}")
    
    if echo "$RESPONSE" | grep -qi "error\|invalid"; then
        print_success "XSS 測試 (svg): 正確拒絕"
    else
        print_fail "XSS 測試 (svg): 可能存在漏洞"
    fi
}

# =====================================================
# 3. JWT 驗證測試
# =====================================================
test_jwt_auth() {
    print_header "3. JWT 驗證測試"
    
    # 測試無 Token
    RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/api/admin/roles")
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    
    if [ "$HTTP_CODE" = "401" ]; then
        print_success "JWT 測試 (無 Token): 正確返回 401"
    else
        print_fail "JWT 測試 (無 Token): 返回 $HTTP_CODE"
    fi
    
    # 測試無效 Token
    RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/api/admin/roles" \
        -H "Authorization: Bearer invalid_token_here")
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    
    if [ "$HTTP_CODE" = "401" ]; then
        print_success "JWT 測試 (無效 Token): 正確返回 401"
    else
        print_fail "JWT 測試 (無效 Token): 返回 $HTTP_CODE"
    fi
    
    # 測試偽造 Token
    RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/api/admin/roles" \
        -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c")
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    
    if [ "$HTTP_CODE" = "401" ]; then
        print_success "JWT 測試 (偽造 Token): 正確返回 401"
    else
        print_fail "JWT 測試 (偽造 Token): 返回 $HTTP_CODE"
    fi
    
    # 測試過期 Token
    RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/api/admin/roles" \
        -H "Authorization: Bearer expired_token")
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    
    if [ "$HTTP_CODE" = "401" ]; then
        print_success "JWT 測試 (過期 Token): 正確返回 401"
    else
        print_fail "JWT 測試 (過期 Token): 返回 $HTTP_CODE"
    fi
}

# =====================================================
# 4. CORS 配置測試
# =====================================================
test_cors() {
    print_header "4. CORS 配置測試"
    
    # 測試跨域請求
    RESPONSE=$(curl -s -I -X OPTIONS "$BASE_URL/api/admin/roles" \
        -H "Origin: http://evil-site.com" \
        -H "Access-Control-Request-Method: GET")
    
    # 檢查是否允許跨域
    if echo "$RESPONSE" | grep -qi "Access-Control-Allow-Origin"; then
        ACAO=$(echo "$RESPONSE" | grep -i "Access-Control-Allow-Origin" | head -1)
        
        if echo "$ACAO" | grep -q "\*"; then
            print_warn "CORS: 允許所有來源 (*)"
            print_warn "建議: 限制允許的來源"
        elif echo "$ACAO" | grep -q "nicespeak"; then
            print_success "CORS: 已限制允許的來源"
        else
            print_warn "CORS: 配置可能需要檢查"
        fi
    else
        print_success "CORS: 未返回 Access-Control-Allow-Origin"
    fi
    
    # 測試允許的方法
    if echo "$RESPONSE" | grep -qi "Access-Control-Allow-Methods"; then
        print_success "CORS: 已配置允許的方法"
    else
        print_warn "CORS: 未配置允許的方法"
    fi
}

# =====================================================
# 5. 速率限制測試
# =====================================================
test_rate_limiting() {
    print_header "5. 速率限制測試"
    
    # 快速發送多個請求
    print_info "發送 20 個快速請求..."
    
    for i in $(seq 1 20); do
        curl -s -o /dev/null "$BASE_URL/health" &
    done
    wait
    
    # 檢查是否有速率限制響應
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"test@test.com","password":"test123"}')
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    
    if [ "$HTTP_CODE" = "429" ]; then
        print_success "速率限制: 正常工作 (429)"
    else
        print_warn "速率限制: 未檢測到 (返回 $HTTP_CODE)"
        print_warn "建議: 配置速率限制"
    fi
}

# =====================================================
# 6. 敏感資訊洩露測試
# =====================================================
test_information_disclosure() {
    print_header "6. 敏感資訊洩露測試"
    
    # 檢查錯誤訊息
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/roles/not-exist-id" \
        -H "Authorization: Bearer invalid")
    
    if echo "$RESPONSE" | grep -qi "stack trace\|trace\|at\."; then
        print_fail "資訊洩露: 錯誤訊息包含堆疊追蹤"
    else
        print_success "資訊洩露: 錯誤訊息未洩露堆疊"
    fi
    
    # 檢查伺服器版本
    HEADERS=$(curl -sI "$BASE_URL/")
    
    if echo "$HEADERS" | grep -qi "server:" | grep -qi "apache\|nginx\|express"; then
        print_warn "伺服器: 標頭洩露伺服器版本"
    else
        print_success "伺服器: 標頭未洩露版本"
    fi
    
    # 檢查 X-Powered-By
    if echo "$HEADERS" | grep -qi "x-powered-by"; then
        print_warn "X-Powered-By: 標頭洩露技術棧"
    else
        print_success "X-Powered-By: 已隱藏"
    fi
}

# =====================================================
# 7. 認證繞過測試
# =====================================================
test_auth_bypass() {
    print_header "7. 認證繞過測試"
    
    # 測試直接路徑訪問
    RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/api/admin/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"admin","password":"admin"}')
    
    if echo "$RESPONSE" | grep -qi "token"; then
        print_success "認證: 登入端點正常工作"
    else
        print_fail "認證: 登入可能存在問題"
    fi
    
    # 測試權限提升
    RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/users" \
        -H "Authorization: Bearer invalid_token")
    
    if echo "$RESPONSE" | grep -qi "Unauthorized\|未授權"; then
        print_success "認證: 未授權訪問正確拒絕"
    else
        print_fail "認證: 未授權訪問可能允許"
    fi
}

# =====================================================
# 測試結果摘要
# =====================================================
print_result() {
    print_header "安全測試結果摘要"
    
    TOTAL=$((PASS_COUNT + FAIL_COUNT + WARN_COUNT))
    
    echo -e "總測試數: ${TOTAL}"
    echo -e "${GREEN}通過: ${PASS_COUNT}${NC}"
    echo -e "${RED}失敗: ${FAIL_COUNT}${NC}"
    echo -e "${YELLOW}警告: ${WARN_COUNT}${NC}"
    echo -e ""
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}🎉 安全測試完成！${NC}"
        exit 0
    else
        echo -e "${RED}❌ 發現安全問題，請修復${NC}"
        exit 1
    fi
}

# =====================================================
# 主程式
# =====================================================
main() {
    echo ""
    echo "=============================================="
    echo "   Security Test"
    echo "   URL: $BASE_URL"
    echo "=============================================="
    
    test_sql_injection
    test_xss
    test_jwt_auth
    test_cors
    test_rate_limiting
    test_information_disclosure
    test_auth_bypass
    
    print_result
}

main "$@"
