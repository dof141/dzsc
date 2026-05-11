<template>
  <div class="dash-board">
    <div class="welcome-banner">
      <div class="text-content">
        <h1>业务概览报表</h1>
        <p>欢迎回来。系统正在处理今天的电商交易，请关注右侧的库存预警。</p>
      </div>
      <div class="date-badge">
        <el-icon><Calendar /></el-icon> {{ new Date().toLocaleDateString() }}
      </div>
    </div>

    <el-row :gutter="24" class="stat-grid">
      <el-col :span="6">
        <div class="stat-block">
          <div class="stat-icon" style="background: #fff7ed; color: #f97316;">
            <el-icon><Money /></el-icon>
          </div>
          <div class="stat-content">
            <div class="label">今日营收</div>
            <div class="value">¥{{ Number(stats.todaySales).toLocaleString() }}</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-block">
          <div class="stat-icon" style="background: #ecfdf5; color: #10b981;">
            <el-icon><Document /></el-icon>
          </div>
          <div class="stat-content">
            <div class="label">今日订单</div>
            <div class="value">{{ stats.todayOrders }}</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-block">
          <div class="stat-icon" style="background: #eff6ff; color: #3b82f6;">
            <el-icon><TrendCharts /></el-icon>
          </div>
          <div class="stat-content">
            <div class="label">月度销售额</div>
            <div class="value">¥{{ Number(stats.monthSales).toLocaleString() }}</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-block">
          <div class="stat-icon" style="background: #fef2f2; color: #ef4444;">
            <el-icon><Warning /></el-icon>
          </div>
          <div class="stat-content">
            <div class="label">库存报警</div>
            <div class="value" style="color: #ef4444;">{{ stats.lowStockCount }} 项</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="24" class="chart-grid">
      <el-col :span="16">
        <el-card class="chart-card">
          <template #header>30天销售趋势</template>
          <div ref="lineChart" class="chart-area"></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="chart-card">
          <template #header>品类销售占比</template>
          <div ref="pieChart" class="chart-area"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="24">
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>订单状态漏斗</template>
          <div ref="barChart" class="chart-area"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            急需补货清单 
            <el-tag type="danger" round style="margin-left: 10px;">{{ stats.lowStockCount }} 项</el-tag>
          </template>
          <el-table :data="stats.lowStockList" style="width: 100%" height="280">
            <el-table-column prop="productName" label="商品名称" min-width="160" />
            <el-table-column prop="quantity" label="当前库存" width="100" align="center">
              <template #default="{ row }">
                <span style="color: #ef4444; font-weight: 800; font-size: 16px;">{{ row.quantity }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="safetyStock" label="安全底线" width="100" align="center" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { Money, Document, TrendCharts, Warning, Calendar } from '@element-plus/icons-vue'
import { getDashboardStats } from '../api/modules'

const stats = reactive({
  todaySales: 0, todayOrders: 0, monthSales: 0, lowStockCount: 0,
  salesTrend: [], categorySales: [], orderStatusDist: [], lowStockList: []
})

const lineChart = ref(null)
const pieChart = ref(null)
const barChart = ref(null)
let charts = []

const initCharts = () => {
  charts.forEach(c => c.dispose())
  charts = []

  if (lineChart.value) {
    const c = echarts.init(lineChart.value)
    c.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'category', data: stats.salesTrend.map(i => i.DATE_STR || i.date_str), axisLine: { lineStyle: { color: '#e5e7eb' } }, axisLabel: { color: '#6b7280' } },
      yAxis: { type: 'value', splitLine: { lineStyle: { color: '#f3f4f6', type: 'dashed' } }, axisLabel: { color: '#6b7280' } },
      series: [{
        name: '销售额', data: stats.salesTrend.map(i => i.AMOUNT || i.amount),
        type: 'line', smooth: true, color: '#f97316', symbolSize: 8,
        areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: 'rgba(249, 115, 22, 0.2)' }, { offset: 1, color: 'rgba(249, 115, 22, 0)' }]) }
      }]
    })
    charts.push(c)
  }

  if (pieChart.value) {
    const c = echarts.init(pieChart.value)
    c.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: 0, icon: 'circle', textStyle: { color: '#6b7280' } },
      series: [{
        type: 'pie', radius: ['45%', '70%'], center: ['50%', '45%'],
        data: stats.categorySales.map(i => ({ name: i.CATEGORY_NAME || i.category_name, value: i.AMOUNT || i.amount })),
        label: { show: false },
        itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
        color: ['#f97316', '#3b82f6', '#10b981', '#f43f5e', '#8b5cf6']
      }]
    })
    charts.push(c)
  }

  if (barChart.value) {
    const c = echarts.init(barChart.value)
    const map = { PENDING: '待处理', PAID: '已支付', SHIPPED: '已发货', COMPLETED: '已完成', CANCELLED: '已取消' }
    c.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'value', splitLine: { lineStyle: { color: '#f3f4f6', type: 'dashed' } }, axisLabel: { color: '#6b7280' } },
      yAxis: { type: 'category', data: stats.orderStatusDist.map(i => map[i.STATUS || i.status] || i.STATUS), axisLine: { lineStyle: { color: '#e5e7eb' } }, axisLabel: { color: '#6b7280' } },
      series: [{
        type: 'bar', data: stats.orderStatusDist.map(i => i.COUNT || i.count),
        itemStyle: { color: '#f97316', borderRadius: [0, 6, 6, 0] }, barWidth: 20
      }]
    })
    charts.push(c)
  }
}

const loadData = async () => {
  const res = await getDashboardStats()
  Object.assign(stats, res.data)
  nextTick(initCharts)
}

onMounted(loadData)
window.addEventListener('resize', () => charts.forEach(c => c.resize()))
</script>

<style scoped>
.dash-board {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.welcome-banner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  padding: 24px 30px;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.02);
}

.welcome-banner h1 {
  font-size: 24px;
  font-weight: 800;
  color: #111827;
  margin: 0 0 8px;
}

.welcome-banner p {
  color: #6b7280;
  margin: 0;
  font-size: 15px;
}

.date-badge {
  background: #f9fafb;
  padding: 10px 20px;
  border-radius: 12px;
  font-weight: 800;
  color: #374151;
  display: flex;
  align-items: center;
  gap: 8px;
}

.stat-block {
  background: white;
  padding: 24px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.02);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 16px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 28px;
}

.stat-content {
  display: flex;
  flex-direction: column;
}

.stat-content .label {
  font-size: 14px;
  font-weight: 800;
  color: #6b7280;
  margin-bottom: 4px;
}

.stat-content .value {
  font-size: 26px;
  font-weight: 900;
  color: #111827;
}

.chart-area {
  width: 100%;
  height: 320px;
}

.chart-grid {
  margin-bottom: 0;
}
</style>
