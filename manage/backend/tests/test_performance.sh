# =====================================================
# 效能測試腳本
# Performance Test Script
# =====================================================
# Usage: ./test_performance.sh [base_url]
# =====================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="${1:-http://localhost:8080}"

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# =====================================================
# 1. API 回應時間測試
# =====================================================
test_api_response_time() {
    print_header "1. API 回應時間測試"
    
    # 測試健康檢查
    TIME=$(curl -s -o /dev/null -w "%{time_total}" "$BASE_URL/health")
    TIME_MS=$(echo "$TIME * 1000" | bc | cut -d'.' -f1)
    
    print_info "Health Check: ${TIME_MS}ms"
    if [ "$TIME_MS" -lt 100 ]; then
        print_success "健康檢查 < 100ms: ${TIME_MS}ms ✓"
    else
        print_fail "健康檢查 >= 100ms: ${TIME_MS}ms ✗"
    fi
    
    # 測試角色列表
    TIME=$(curl -s -o /dev/null -w "%{time_total}" \
        -H "Authorization: Bearer test" \
        "$BASE_URL/api/admin/roles")
    TIME_MS=$(echo "$TIME * 1000" | bc | cut -d'.' -f1)
    
    print_info "角色列表: ${TIME_MS}ms"
    if [ "$TIME_MS" -lt 200 ]; then
        print_success "角色列表 < 200ms: ${TIME_MS}ms ✓"
    else
        print_fail "角色列表 >= 200ms: ${TIME_MS}ms ✗"
    fi
    
    # 測試權限列表
    TIME=$(curl -s -o /dev/null -w "%{time_total}" \
        -H "Authorization: Bearer test" \
        "$BASE_URL/api/admin/permissions")
    TIME_MS=$(echo "$TIME * 1000" | bc | cut -d'.' -f1)
    
    print_info "權限列表: ${TIME_MS}ms"
    if [ "$TIME_MS" -lt 200 ]; then
        print_success "權限列表 < 200ms: ${TIME_MS}ms ✓"
    else
        print_fail "權限列表 >= 200ms: ${TIME_MS}ms ✗"
    fi
}

# =====================================================
# 2. 並發連線測試
# =====================================================
test_concurrent_requests() {
    print_header "2. 並發連線測試"
    
    CONCURRENT="${2:-10}"
    REQUESTS="${3:-50}"
    
    print_info "發送 $REQUESTS 個請求，並發數: $CONCURRENT"
    
    # 使用 curl 進行並發測試
    START_TIME=$(date +%s.%N)
    
    for i in $(seq 1 $REQUESTS); do
        curl -s -o /dev/null "$BASE_URL/health" &
        
        # 控制並發數量
        if [ $((i % CONCURRENT)) -eq 0 ]; then
            wait
        fi
    done
    
    wait
    END_TIME=$(date +%s.%N)
    
    TOTAL_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    REQ_PER_SEC=$(echo "scale=2; $REQUESTS / $TOTAL_TIME" | bc)
    
    print_info "總時間: ${TOTAL_TIME}s"
    print_info "每秒請求數: ${REQ_PER_SEC}"
    
    if (( $(echo "$REQ_PER_SEC > 50" | bc -l) )); then
        print_success "吞吐量 > 50 req/s: ${REQ_PER_SEC} req/s ✓"
    else
        print_fail "吞吐量 <= 50 req/s: ${REQ_PER_SEC} req/s ✗"
    fi
}

# =====================================================
# 3. 資料庫查詢測試
# =====================================================
test_database_queries() {
    print_header "3. 資料庫查詢測試"
    
    # 測試簡單查詢
    TIME=$(curl -s -o /dev/null -w "%{time_total}" \
        -H "Authorization: Bearer test" \
        "$BASE_URL/api/admin/roles?limit=10")
    TIME_MS=$(echo "$TIME * 1000" | bc | cut -d'.' -f1)
    
    print_info "簡單查詢 (10 筆): ${TIME_MS}ms"
    if [ "$TIME_MS" -lt 100 ]; then
        print_success "簡單查詢 < 100ms: ${TIME_MS}ms ✓"
    else
        print_fail "簡單查詢 >= 100ms: ${TIME_MS}ms ✗"
    fi
    
    # 測試複雜查詢 (帶關聯)
    TIME=$(curl -s -o /dev/null -w "%{time_total}" \
        -H "Authorization: Bearer test" \
        "$BASE_URL/api/admin/roles/role-001")
    TIME_MS=$(echo "$TIME * 1000" | bc | cut -d'.' -f1)
    
    print_info "關聯查詢: ${TIME_MS}ms"
    if [ "$TIME_MS" -lt 200 ]; then
        print_success "關聯查詢 < 200ms: ${TIME_MS}ms ✓"
    else
        print_fail "關聯查詢 >= 200ms: ${TIME_MS}ms ✗"
    fi
}

# =====================================================
# 4. 前端載入效能測試
# =====================================================
test_frontend_performance() {
    print_header "4. 前端載入效能測試"
    
    FRONTEND_URL="${2:-http://localhost:3000}"
    
    # 首頁載入時間
    TIME=$(curl -s -o /dev/null -w "%{time_total}" "$FRONTEND_URL/")
    TIME_MS=$(echo "$TIME * 1000" | bc | cut -d'.' -f1)
    
    print_info "首頁載入時間: ${TIME_MS}ms"
    if [ "$TIME_MS" -lt 2000 ]; then
        print_success "首頁載入 < 2s: ${TIME_MS}ms ✓"
    else
        print_fail "首頁載入 >= 2s: ${TIME_MS}ms ✗"
    fi
    
    # 首頁下載大小
    SIZE=$(curl -s -o /dev/null -w "%{size_download}" "$FRONTEND_URL/")
    SIZE_KB=$(echo "scale=2; $SIZE / 1024" | bc)
    
    print_info "首頁大小: ${SIZE_KB}KB"
    if (( $(echo "$SIZE_KB < 500" | bc -l) )); then
        print_success "首頁大小 < 500KB: ${SIZE_KB}KB ✓"
    else
        print_fail "首頁大小 >= 500KB: ${SIZE_KB}KB ✗"
    fi
}

# =====================================================
# 5. 記憶體使用量測試
# =====================================================
test_memory_usage() {
    print_header "5. 記憶體使用量測試"
    
    # 檢查服務狀態
    if command -v docker &> /dev/null; then
        print_info "Docker 容器記憶體使用:"
        
        BACKEND_MEM=$(docker stats --no-stream --format "{{.MemUsage}}" nicespeak-backend 2>/dev/null || echo "N/A")
        MYSQL_MEM=$(docker stats --no-stream --format "{{.MemUsage}}" nicespeak-mysql 2>/dev/null || echo "N/A")
        
        echo "  Backend: $BACKEND_MEM"
        echo "  MySQL: $MYSQL_MEM"
        
        print_success "記憶體監控正常"
    else
        print_info "Docker 未安裝，跳過記憶體測試"
    fi
}

# =====================================================
# 6. 壓力測試
# =====================================================
test_stress() {
    print_header "6. 壓力測試"
    
    DURATION="${2:-10}"
    print_info "持續測試 ${DURATION} 秒..."
    
    # 持續發送請求
    START_TIME=$(date +%s)
    REQUEST_COUNT=0
    ERROR_COUNT=0
    
    while [ $(($(date +%s) - START_TIME)) -lt $DURATION ]; do
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/health")
        
        if [ "$RESPONSE" = "200" ]; then
            ((REQUEST_COUNT++))
        else
            ((ERROR_COUNT++))
        fi
    done
    
    DURATION_ACTUAL=$(($(date +%s) - START_TIME))
    REQ_PER_SEC=$(echo "scale=2; $REQUEST_COUNT / $DURATION_ACTUAL" | bc)
    ERROR_RATE=$(echo "scale=2; $ERROR_COUNT * 100 / ($REQUEST_COUNT + $ERROR_COUNT)" | bc)
    
    print_info "成功請求: $REQUEST_COUNT"
    print_info "錯誤請求: $ERROR_COUNT"
    print_info "每秒請求數: $REQ_PER_SEC"
    print_info "錯誤率: ${ERROR_RATE}%"
    
    if (( $(echo "$ERROR_RATE < 1" | bc -l) )); then
        print_success "錯誤率 < 1%: ${ERROR_RATE}% ✓"
    else
        print_fail "錯誤率 >= 1%: ${ERROR_RATE}% ✗"
    fi
}

# =====================================================
# 主程式
# =====================================================
main() {
    echo ""
    echo "=============================================="
    echo "   Performance Test"
    echo "   URL: $BASE_URL"
    echo "=============================================="
    
    test_api_response_time
    test_concurrent_requests
    test_database_queries
    test_frontend_performance
    test_memory_usage
    test_stress
    
    echo ""
    echo "=============================================="
    echo "   Performance Test Complete"
    echo "=============================================="
}

main "$@"
