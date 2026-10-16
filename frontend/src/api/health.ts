const API_URL = import.meta.env.VITE_API_URL ?? ''

export async function fetchHealth(): Promise<{ status: string; db: string }> {
  const res = await fetch(`${API_URL}/api/v1/health`)
  if (!res.ok) throw new Error(`API ${res.status}`)
  return res.json()
}
