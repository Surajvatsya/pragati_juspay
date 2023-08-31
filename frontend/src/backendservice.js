// frontend/src/backendService.js
const API_BASE_URL = '/api';

async function getHelloMessage() {
  try {
    const response = await fetch(`${API_BASE_URL}/hello`);
    const data = await response.json();
    return data.message;
  } catch (error) {
    console.error('Error:', error);
    return '';
  }
}

export { getHelloMessage };
