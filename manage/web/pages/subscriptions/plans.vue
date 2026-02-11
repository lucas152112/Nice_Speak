<template>
  <div class="subscription-plans">
    <div class="page-header">
      <h1>方案管理</h1>
      <el-button type="primary" @click="showCreateDialog = true">
        新增方案
      </el-button>
    </div>

    <div class="plans-grid">
      <el-card 
        v-for="plan in plans" 
        :key="plan.id"
        class="plan-card"
        :class="{ 'featured': plan.featured }"
      >
        <div class="plan-header">
          <h3>{{ plan.name }}</h3>
          <div class="plan-price">
            <span class="currency">$</span>
            <span class="amount">{{ plan.price }}</span>
            <span class="period">/{{ plan.period }}</span>
          </div>
        </div>
        
        <ul class="plan-features">
          <li v-for="(feature, idx) in plan.features" :key="idx">
            <el-icon><Check /></el-icon>
            {{ feature }}
          </li>
        </ul>
        
        <div class="plan-discount" v-if="plan.discount">
          {{ plan.discount }}
        </div>
        
        <div class="plan-actions">
          <el-button type="primary" @click="editPlan(plan)">編輯</el-button>
          <el-button @click="viewSubscribers(plan)">查看訂閱</el-button>
        </div>
      </el-card>
    </div>

    <!-- 新增/編輯 Dialog -->
    <el-dialog
      v-model="showCreateDialog"
      :title="isEditing ? '編輯方案' : '新增方案'"
      width="500px"
    >
      <el-form :model="planForm" label-width="100px">
        <el-form-item label="方案名稱">
          <el-input v-model="planForm.name" placeholder="如: 進階版" />
        </el-form-item>
        <el-form-item label="方案代碼">
          <el-input v-model="planForm.code" placeholder="如: premium" />
        </el-form-item>
        <el-form-item label="價格">
          <el-input-number v-model="planForm.price" :min="0" :precision="2" />
        </el-form-item>
        <el-form-item label="週期">
          <el-select v-model="planForm.period">
            <el-option label="月" value="月" />
            <el-option label="年" value="年" />
          </el-select>
        </el-form-item>
        <el-form-item label="促銷折扣">
          <el-input v-model="planForm.discount" placeholder="如: 首月 5 折" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary">確定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'

const showCreateDialog = ref(false)
const isEditing = ref(false)

const plans = ref([
  {
    id: 'plan-free',
    name: '免費版',
    code: 'free',
    price: 0,
    period: '月',
    features: ['每日 3 次練習', '5 個情境模板', '基礎發音評估'],
    discount: null,
    featured: false,
  },
  {
    id: 'plan-basic',
    name: '基礎版',
    code: 'basic',
    price: 299,
    period: '月',
    features: ['每日 30 次練習', '50 個情境模板', '完整發音評估', 'Email 支援'],
    discount: '首月 5 折',
    featured: false,
  },
  {
    id: 'plan-premium',
    name: '進階版',
    code: 'premium',
    price: 599,
    period: '月',
    features: ['無限練習', '全部情境模板', 'AI 對話練習', '專屬客服', '優先新功能'],
    discount: '首年 8 折',
    featured: true,
  },
])

const planForm = reactive({
  id: '',
  name: '',
  code: '',
  price: 0,
  period: '月',
  discount: '',
})

function editPlan(plan: any) {
  Object.assign(planForm, plan)
  isEditing.value = true
  showCreateDialog.value = true
}

function viewSubscribers(plan: any) {
  navigateTo(`/subscriptions/orders?plan=${plan.code}`)
}
</script>

<style scoped>
.subscription-plans { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }

.plans-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.plan-card {
  border-radius: 12px;
  transition: transform 0.3s;
}
.plan-card:hover { transform: translateY(-5px); }
.plan-card.featured {
  border: 2px solid #409eff;
}

.plan-header { text-align: center; margin-bottom: 20px; }
.plan-header h3 { margin: 0 0 10px; font-size: 20px; }
.plan-price { color: #303133; }
.plan-price .currency { font-size: 16px; vertical-align: top; }
.plan-price .amount { font-size: 36px; font-weight: 600; }
.plan-price .period { font-size: 14px; color: #909399; }

.plan-features {
  list-style: none;
  padding: 0;
  margin: 0 0 20px;
}
.plan-features li {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 0;
  color: #606266;
}
.plan-features li .el-icon { color: #67c23a; }

.plan-discount {
  background: #fdf6ec;
  color: #e6a23c;
  padding: 8px;
  border-radius: 4px;
  text-align: center;
  margin-bottom: 20px;
  font-size: 13px;
}

.plan-actions { display: flex; gap: 10px; }
.plan-actions .el-button { flex: 1; }
</style>
