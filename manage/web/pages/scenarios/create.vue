<template>
  <div class="create-scenario">
    <div class="page-header">
      <el-page-header @back="router.back()">
        <template #content>
          <span class="page-title">新增情境模板</span>
        </template>
      </el-page-header>
    </div>

    <el-card shadow="never" class="form-card">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <!-- 基本資訊 -->
        <el-divider content-position="left">基本資訊</el-divider>
        
        <el-form-item label="情境名稱" prop="title">
          <el-input v-model="form.title" placeholder="如: 機場入境" maxlength="100" show-word-limit />
        </el-form-item>
        
        <el-form-item label="情境描述" prop="description">
          <el-input v-model="form.description" type="textarea" rows="3" placeholder="簡短描述這個情境的用途" />
        </el-form-item>
        
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="分類" prop="category">
              <el-select v-model="form.category" placeholder="選擇分類">
                <el-option label="日常生活" value="daily" />
                <el-option label="旅遊" value="travel" />
                <el-option label="商務" value="business" />
                <el-option label="教育" value="education" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="難度" prop="level">
              <el-select v-model="form.level" placeholder="選擇難度">
                <el-option label="入門" value="beginner" />
                <el-option label="中級" value="intermediate" />
                <el-option label="進階" value="advanced" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="標籤">
              <el-select v-model="form.tags" multiple placeholder="選擇標籤" allow-create filterable>
                <el-option label="機場" value="airport" />
                <el-option label="餐廳" value="restaurant" />
                <el-option label="購物" value="shopping" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <!-- 情境圖片 -->
        <el-form-item label="情境圖片">
          <el-upload
            action="#"
            list-type="picture-card"
            :auto-upload="false"
            :on-change="handleImageChange"
            :on-remove="handleImageRemove"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">建議尺寸 800x400，支援 JPG/PNG</div>
        </el-form-item>

        <!-- 對話內容 -->
        <el-divider content-position="left">對話內容</el-divider>
        
        <div class="dialogues-section">
          <div v-for="(dialogue, index) in form.dialogues" :key="index" class="dialogue-item">
            <div class="dialogue-header">
              <span class="dialogue-title">對話 {{ index + 1 }}</span>
              <el-button 
                v-if="form.dialogues.length > 1"
                type="danger" 
                link 
                size="small"
                @click="removeDialogue(index)"
              >
                刪除
              </el-button>
            </div>
            
            <el-row :gutter="10" class="dialogue-content">
              <el-col :span="12">
                <el-form-item label="角色A" label-width="60px">
                  <el-select v-model="dialogue.role_a" placeholder="選擇角色">
                    <el-option label="客服人員" value="agent" />
                    <el-option label="顧客" value="customer" />
                    <el-option label="銀行行員" value="banker" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="角色B" label-width="60px">
                  <el-select v-model="dialogue.role_b" placeholder="選擇角色">
                    <el-option label="客服人員" value="agent" />
                    <el-option label="顧客" value="customer" />
                    <el-option label="銀行行員" value="banker" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            
            <div class="dialogue-lines">
              <div v-for="(line, lineIdx) in dialogue.lines" :key="lineIdx" class="line-item">
                <el-tag size="small" :type="line.speaker === 'A' ? 'primary' : 'success'">
                  {{ line.speaker === 'A' ? '角色A' : '角色B' }}
                </el-tag>
                <el-input
                  v-model="line.text"
                  placeholder="輸入對話內容"
                  type="textarea"
                  rows="2"
                />
                <el-button 
                  v-if="dialogue.lines.length > 1"
                  type="danger" 
                  link 
                  size="small"
                  @click="removeLine(dialogue, lineIdx)"
                >
                  刪除
                </el-button>
              </div>
              <el-button type="primary" link size="small" @click="addLine(dialogue)">
                + 新增對話行
              </el-button>
            </div>
          </div>
          
          <el-button type="primary" plain @click="addDialogue">
            + 新增對話區塊
          </el-button>
        </div>

        <!-- 提示詞 -->
        <el-divider content-position="left">AI 提示詞</el-divider>
        
        <el-form-item label="系統提示詞">
          <el-input
            v-model="form.system_prompt"
            type="textarea"
            rows="4"
            placeholder="設定 AI 扮演角色的行為描述"
          />
        </el-form-item>
        
        <el-form-item label="使用者提示詞">
          <el-input
            v-model="form.user_prompt"
            type="textarea"
            rows="3"
            placeholder="使用者看到的提示說明"
          />
        </el-form-item>

        <!-- 提交按鈕 -->
        <el-form-item>
          <el-button @click="saveDraft">儲存草稿</el-button>
          <el-button type="primary" @click="submit" :loading="submitLoading">
            儲存並發布
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const formRef = ref()
const submitLoading = ref(false)

const form = reactive({
  title: '',
  description: '',
  category: '',
  level: '',
  tags: [] as string[],
  image_url: '',
  dialogues: [
    {
      role_a: 'agent',
      role_b: 'customer',
      lines: [
        { speaker: 'A', text: '' },
        { speaker: 'B', text: '' },
      ],
    },
  ],
  system_prompt: '',
  user_prompt: '',
})

const rules = {
  title: [{ required: true, message: '請輸入情境名稱', trigger: 'blur' }],
  category: [{ required: true, message: '請選擇分類', trigger: 'change' }],
  level: [{ required: true, message: '請選擇難度', trigger: 'change' }],
}

function addDialogue() {
  form.dialogues.push({
    role_a: 'agent',
    role_b: 'customer',
    lines: [{ speaker: 'A', text: '' }, { speaker: 'B', text: '' }],
  })
}

function removeDialogue(index: number) {
  form.dialogues.splice(index, 1)
}

function addLine(dialogue: any) {
  const newSpeaker = dialogue.lines.length % 2 === 0 ? 'A' : 'B'
  dialogue.lines.push({ speaker: newSpeaker, text: '' })
}

function removeLine(dialogue: any, index: number) {
  dialogue.lines.splice(index, 1)
}

function handleImageChange(file: any) {
  form.image_url = file.raw
}

function handleImageRemove() {
  form.image_url = ''
}

async function saveDraft() {
  ElMessage.success('草稿已儲存')
}

async function submit() {
  try {
    await formRef.value.validate()
    submitLoading.value = true
    // TODO: API call
    await new Promise(r => setTimeout(r, 1000))
    ElMessage.success('情境已發布')
    router.push('/scenarios')
  } catch (error) {
    console.error(error)
  } finally {
    submitLoading.value = false
  }
}
</script>

<style scoped>
.create-scenario { padding: 20px; }
.page-header { margin-bottom: 20px; }
.page-title { font-size: 18px; font-weight: 600; }
.form-card { margin-bottom: 20px; }
.dialogues-section { padding: 10px 0; }
.dialogue-item {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
}
.dialogue-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.dialogue-title { font-weight: 600; color: #303133; }
.dialogue-lines { margin-top: 12px; }
.line-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  margin-bottom: 10px;
}
.line-item .el-textarea { flex: 1; }
.upload-tip { font-size: 12px; color: #909399; margin-top: 8px; }
</style>
