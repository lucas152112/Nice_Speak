<template>
  <div class="system-parameters">
    <div class="page-header">
      <h1>系統參數</h1>
      <el-button type="primary" @click="saveSettings">儲存設定</el-button>
    </div>

    <el-form :model="settings" label-width="200px" class="settings-form">
      <!-- 試用期設定 -->
      <el-card shadow="never" class="settings-card">
        <template #header>
          <div class="card-header">
            <h3>試用期設定</h3>
          </div>
        </template>
        
        <el-form-item label="免費試用天數">
          <el-input-number v-model="settings.free_trial_days" :min="0" :max="30" />
          <span class="form-tip">新用戶註冊後免費試用天數</span>
        </el-form-item>
        
        <el-form-item label="評估試用天數">
          <el-input-number v-model="settings.evaluation_trial_days" :min="0" :max="30" />
          <span class="form-tip">Email 驗證後可獲得的評估試用天數</span>
        </el-form-item>
      </el-card>

      <!-- 練習限制 -->
      <el-card shadow="never" class="settings-card">
        <template #header>
          <h3>練習限制</h3>
        </template>
        
        <el-form-item label="免費版每日練習次數">
          <el-input-number v-model="settings.free_daily_limit" :min="0" :max="100" />
          <span class="form-tip">0 表示無限制</span>
        </el-form-item>
        
        <el-form-item label="每次練習對話輪數">
          <el-input-number v-model="settings.dialogue_rounds" :min="3" :max="20" />
        </el-form-item>
        
        <el-form-item label="每日練習上限（付費用戶）">
          <el-input-number v-model="settings.paid_daily_limit" :min="0" :max="1000" />
          <span class="form-tip">0 表示無限制</span>
        </el-form-item>
      </el-card>

      <!-- 分數設定 -->
      <el-card shadow="never" class="settings-card">
        <template #header>
          <h3>評分權重</h3>
        </template>
        
        <el-form-item label="發音分數權重">
          <el-slider v-model="settings.pronunciation_weight" :min="0" :max="100" show-input />
          <span class="form-tip">發音評估在總分中的佔比 (%)</span>
        </el-form-item>
        
        <el-form-item label="語法分數權重">
          <el-slider v-model="settings.grammar_weight" :min="0" :max="100" show-input />
        </el-form-item>
        
        <el-form-item label="用詞分數權重">
          <el-slider v-model="settings.vocabulary_weight" :min="0" :max="100" show-input />
        </el-form-item>
        
        <el-form-item label="流暢度分數權重">
          <el-slider v-model="settings.fluency_weight" :min="0" :max="100" show-input />
        </el-form-item>
        
        <div class="weight-summary">
          <el-alert 
            :title="`總權重: ${totalWeight}%`" 
            :type="totalWeight === 100 ? 'success' : 'warning'"
            :closable="false"
            show-icon
          />
        </div>
      </el-card>

      <!-- 等級設定 -->
      <el-card shadow="never" class="settings-card">
        <template #header>
          <h3>等級設定</h3>
        </template>
        
        <el-form-item label="升級所需總分">
          <el-input-number v-model="settings.level_up_score" :min="100" :max="10000" :step="100" />
          <span class="form-tip">每次練習最高可獲得 100 分</span>
        </el-form-item>
        
        <el-form-item label="升級所需連續練習次數">
          <el-input-number v-model="settings.level_up_consecutive" :min="1" :max="30" />
          <span class="form-tip">連續 N 天完成每日目標</span>
        </el-form-item>
        
        <el-form-item label="5 級折扣">
          <el-input-number v-model="settings.level_5_discount" :min="0" :max="100" :formatter="value => `${value}%`" />
          <span class="form-tip">5 級用戶訂閱折扣</span>
        </el-form-item>
        
        <el-form-item label="10 級折扣">
          <el-input-number v-model="settings.level_10_discount" :min="0" :max="100" :formatter="value => `${value}%`" />
          <span class="form-tip">10 級用戶訂閱折扣</span>
        </el-form-item>
      </el-card>

      <!-- AI 設定 -->
      <el-card shadow="never" class="settings-card">
        <template #header>
          <h3>AI 設定</h3>
        </template>
        
        <el-form-item label="AI 模型">
          <el-select v-model="settings.ai_model" style="width: 200px">
            <el-option label="GPT-4" value="gpt-4" />
            <el-option label="GPT-4 Turbo" value="gpt-4-turbo" />
            <el-option label="Claude 3 Opus" value="claude-3-opus" />
            <el-option label="Claude 3 Sonnet" value="claude-3-sonnet" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="評估溫度">
          <el-slider v-model="settings.ai_temperature" :min="0" :max="2" :step="0.1" :marks="{0: '精確', 2: '創意'}" />
        </el-form-item>
        
        <el-form-item label="最大 Tokens">
          <el-input-number v-model="settings.ai_max_tokens" :min="100" :max="4000" :step="100" />
        </el-form-item>
        
        <el-form-item label="每次評估重試次數">
          <el-input-number v-model="settings.ai_retry_count" :min="0" :max="5" />
        </el-form-item>
      </el-card>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'

const settings = reactive({
  // 試用期
  free_trial_days: 3,
  evaluation_trial_days: 7,
  
  // 練習限制
  free_daily_limit: 10,
  dialogue_rounds: 10,
  paid_daily_limit: 0,
  
  // 評分權重
  pronunciation_weight: 30,
  grammar_weight: 30,
  vocabulary_weight: 20,
  fluency_weight: 20,
  
  // 等級
  level_up_score: 1000,
  level_up_consecutive: 3,
  level_5_discount: 80,
  level_10_discount: 60,
  
  // AI
  ai_model: 'gpt-4-turbo',
  ai_temperature: 0.3,
  ai_max_tokens: 2000,
  ai_retry_count: 2,
})

const totalWeight = computed(() => {
  return settings.pronunciation_weight + 
         settings.grammar_weight + 
         settings.vocabulary_weight + 
         settings.fluency_weight
})

function saveSettings() {
  ElMessage.success('設定已儲存')
}
</script>

<style scoped>
.system-parameters { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }

.settings-card { margin-bottom: 20px; }
.settings-card h3 { margin: 0; font-size: 16px; font-weight: 600; }
.card-header { display: flex; justify-content: space-between; align-items: center; }

.form-tip {
  margin-left: 12px;
  font-size: 12px;
  color: #909399;
}

.weight-summary { margin-top: 16px; }
</style>
