import { createRouter, createWebHistory } from 'vue-router';

const routes = [
  {
    path: '/',
    redirect: '/dashboard',
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/Dashboard.vue'),
    children: [
      {
        path: '',
        name: 'Microservices',
        component: () => import('@/components/MicroserviceList.vue'),
      },
    ],
  },
  {
    path: '/microservices',
    name: 'Microservices',
    component: () => import('@/views/Dashboard.vue'),
    children: [
      {
        path: '',
        name: 'MicroserviceList',
        component: () => import('@/components/MicroserviceList.vue'),
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
