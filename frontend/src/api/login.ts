import { request } from '@/utils/request'
export const AuthApi = {
  login: (credentials: { username: string; password: string }) => {
    const entryCredentials = {
      username: LicenseGenerator.sqlbotEncrypt(credentials.username),
      password: LicenseGenerator.sqlbotEncrypt(credentials.password),
    }
    return request.post<{
      data: any
      token: string
    }>('/login/access-token', entryCredentials, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    })
  },
  logout: () => request.post('/auth/logout'),
  info: () => request.get('/user/info'),
}
