# =====================================================
# 前端整合測試腳本
# Frontend Integration Test Script
# =====================================================
# Usage: ./test_frontend.sh [base_url]
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

# 測試變數
BASE_URL="${1:-http://localhost:3000}"
BACKEND_URL="${2:-http://localhost:8080}"

# =====================================================
# 1. 頁面載入測試
# =====================================================
test_page_load() {
    print_header "1. 頁面載入測試"
    
    # 測試登入頁面
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/login")
    if [ "$RESPONSE" = "200" ]; then
        print_success "GET /login - 登入頁面載入正常"
    else
        print_fail "/login 返回狀態碼: $RESPONSE"
    fi
    
    # 測試儀表板頁面
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
    if [ "$RESPONSE" = "200" ]; then
        print_success "GET / - 首頁載入正常"
    else
        print_fail "/ 返回狀態碼: $RESPONSE"
    fi
    
    # 測試角色管理頁面
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/settings/roles")
    if [ "$RESPONSE" = "200" ]; then
        print_success "GET /settings/roles - 角色管理頁面載入正常"
    else
        print_fail "/settings/roles 返回狀態碼: $RESPONSE"
    fi
    
    # 測試客戶管理頁面
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/customers")
    if [ "$RESPONSE" = "200" ]; then
        print_success "GET /customers - 客戶管理頁面載入正常"
    else
        print_fail "/customers 返回狀態碼: $RESPONSE"
    fi
    
    # 測試情境管理頁面
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/scenarios")
    if [ "$RESPONSE" = "200" ]; then
        print_success "GET /scenarios - 情境管理頁面載入正常"
    else
        print_fail "/scenarios 返回狀態碼: $RESPONSE"
    fi
}

# =====================================================
# 2. 資源載入測試
# =====================================================
test_resources() {
    print_header "2. 資源載入測試"
    
    # 測試 JavaScript 資源
    JS_FILES=$(curl -s "$BASE_URL/" | grep -oP 'src="[^"]+\.js"' | sed 's/src="//;s/"$//')
    
    for js in $JS_FILES; do
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$js")
        if [ "$RESPONSE" = "200" ]; then
            print_success "JS: $js 載入正常"
        else
            print_fail "JS: $js 返回狀態碼: $RESPONSE"
        fi
    done
    
    # 測試 CSS 資源
    CSS_FILES=$(curl -s "$BASE_URL/" | grep -oP 'href="[^"]+\.css"' | sed 's/href="//;s/"$//')
    
    for css in $CSS_FILES; do
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$css")
        if [ "$RESPONSE" = "200" ]; then
            print_success "CSS: $css 載入正常"
        else
            print_fail "CSS: $css 返回狀態碼: $RESPONSE"
        fi
    done
}

# =====================================================
# 3. API 串接測試
# =====================================================
test_api_integration() {
    print_header "3. API 串接測試"
    
    # 測試後端健康檢查
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/health")
    if [ "$RESPONSE" = "200" ]; then
        print_success "Backend Health Check: 正常"
    else
        print_fail "Backend Health Check: $RESPONSE"
    fi
    
    # 測試後端 API 可訪問
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/api/admin/roles")
    if [ "$RESPONSE" = "401" ]; then
        print_success "API Access: 未授權訪問正確拒絕"
    elif [ "$RESPONSE" = "200" ]; then
        print_success "API Access: 已授權訪問正常"
    else
        print_fail "API Access: 返回狀態碼: $RESPONSE"
    fi
}

# =====================================================
# 4. 響應式設計測試
# =====================================================
test_responsive() {
    print_header "4. 響應式設計測試"
    
    # 測試不同 User-Agent
    USER_AGENTS=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)"
        "Mozilla/5.0 (Linux; Android 10; SM-G975F)"
    )
    
    for ua in "${USER_AGENTS[@]}"; do
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "User-Agent: $ua" \
            "$BASE_URL/")
        
        if [ "$RESPONSE" = "200" ]; then
            print_success "Responsive: 不同 UA 訪問正常"
        else
            print_fail "Responsive: UA 測試返回: $RESPONSE"
        fi
    done
}

# =====================================================
# 5. SSL/TLS 測試 (如果配置)
# =====================================================
test_security_headers() {
    print_header "5. 安全標頭測試"
    
    RESPONSE=$(curl -sI "$BASE_URL/" | grep -i "content-type\|x-frame-options\|x-xss-protection")
    
    if echo "$RESPONSE" | grep -qi "x-frame-options"; then
        print_success "X-Frame-Options: 已配置"
    else
        print_fail "X-Frame-Options: 未配置"
    fi
    
    if echo "$RESPONSE" | grep -qi "x-content-type-options"; then
        print_success "X-Content-Type-Options: 已配置"
    else
        print_fail "X-Content-Type-Options: 未配置"
    fi
}

# =====================================================
# 6. 效能測試
# =====================================================
test_performance() {
    print_header "6. 效能測試"
    
    # 首頁載入時間
    TIME_TOTAL=$(curl -s -o /dev/null -w "%{time_total}" "$BASE_URL/")
    TIME_TOTAL_MS=$(echo "$TIME_TOTAL * 1000" | bc | cut -d'.' -f1)
    
    if [ "$TIME_TOTAL_MS" -lt 2000 ]; then
        print_success "首頁載入時間: ${TIME_TOTAL_MS}ms (目標 < 2s)"
    else
        print_fail "首頁載入時間: ${TIME_TOTAL_MS}ms (目標 < 2s)"
    fi
    
    # API 回應時間
    API_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$BACKEND_URL/health")
    API_TIME_MS=$(echo "$API_TIME * 1000" | bc | cut -d'.' -f1)
    
    if [ "$API_TIME_MS" -lt 500 ]; then
        print_success "API 健康檢查: ${API_TIME_MS}ms (目標 < 500ms)"
    else
        print_fail "API 健康檢查: ${API_TIME_MS}ms (目標 < 500ms)"
    fi
}

# =====================================================
# 7. 錯誤頁面測試
# =====================================================
test_error_pages() {
    print_header "7. 錯誤頁面測試"
    
    # 測試 404 頁面
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/not-found-page")
    if [ "$RESPONSE" = "404" ]; then
        print_success "404 Error: 正確返回 404"
    else
        print_fail "404 Error: 返回 $RESPONSE"
    fi
}

# =====================================================
# 測試結果摘要
# =====================================================
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
        echo -e "${RED}❌ 有測試失敗${NC}"
        exit 1
    fi
}

# =====================================================
# 主程式
# =====================================================
main() {
    echo ""
    echo "=============================================="
    echo "   Frontend Integration Test"
    echo "   Frontend: $BASE_URL"
    echo "   Backend: $BACKEND_URL"
    echo "=============================================="
    
    test_page_load
    test_resources
    test_api_integration
    test_responsive
    test_security_headers
    test_performance
    test_error_pages
    
    print_result
}

main "$@"
