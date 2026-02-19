# API Integration Guide

This document provides detailed integration examples for using the Whisper STT API with third-party applications.

## Table of Contents

- [API Overview](#api-overview)
- [OpenWebUI](#openwebui)
- [LibreChat](#librechat)
- [Flowise](#flowise)
- [LangChain](#langchain)
- [Custom Python Application](#custom-python-application)
- [Custom Node.js Application](#custom-nodejs-application)
- [REST API Reference](#rest-api-reference)

---

## API Overview

The Whisper STT API is **OpenAI API compatible**, meaning any application that works with OpenAI's Whisper API can be configured to use this local server.

**Base URL:** `http://localhost:7861/v1`

**Authentication:** None required (local server)

**Supported Audio Formats:** WAV, MP3, FLAC, M4A, WEBM

---

## OpenWebUI

### Configuration

1. Navigate to **Settings** → **Speech-to-Text**

2. Configure:
   ```
   Provider: OpenAI
   Base URL: http://localhost:7861/v1
   API Key: (leave empty or enter "local")
   Model: small
   ```

3. Test the connection by clicking "Test" button

### LAN Access (OpenWebUI on different machine)

1. Edit `~/.config/hypr-stt/env`:
   ```bash
   export WHISPER_HOST=0.0.0.0
   ```

2. Restart server:
   ```bash
   systemctl --user restart whisper-api.service
   ```

3. In OpenWebUI, use your machine's IP:
   ```
   Base URL: http://192.168.1.100:7861/v1
   ```

4. Ensure firewall allows port 7861:
   ```bash
   sudo ufw allow 7861/tcp
   ```

---

## LibreChat

### Configuration

Add to your `librechat.yaml`:

```yaml
speech:
  stt:
    provider: "openai"
    apiKey: "local-key"  # Not validated for local server
    model: "small"
    baseURL: "http://localhost:7861/v1"
  
  tts:
    # Optional: Configure TTS if needed
    provider: "openai"
    apiKey: "your-openai-key"
    model: "tts-1"
```

### Environment Variables

Alternatively, set environment variables:

```bash
export STT_PROVIDER=openai
export STT_BASE_URL=http://localhost:7861/v1
export STT_API_KEY=local-key
export STT_MODEL=small
```

---

## Flowise

### Using HTTP Request Node

1. Add **HTTP Request** node to your flow

2. Configure:
   - **Method:** POST
   - **URL:** `http://localhost:7861/v1/audio/transcriptions`
   - **Headers:**
     ```
     Content-Type: multipart/form-data
     ```
   - **Body (form-data):**
     ```
     file: {{your_audio_file}}
     model: small
     language: en
     response_format: json
     ```

3. Parse response:
   ```javascript
   // Code node after HTTP request
   const transcription = $input.first().json.text;
   return { transcription };
   ```

---

## LangChain

### Python Example

```python
from langchain_community.utilities import SpeechToTextAPI
import requests

class LocalWhisperSTT:
    """Local Whisper STT integration for LangChain."""
    
    def __init__(self, base_url: str = "http://localhost:7861/v1"):
        self.base_url = base_url
    
    def transcribe(self, audio_path: str, language: str = "en") -> str:
        """Transcribe audio file to text."""
        with open(audio_path, 'rb') as f:
            files = {'file': f}
            data = {
                'model': 'small',
                'language': language,
                'response_format': 'json'
            }
            response = requests.post(
                f'{self.base_url}/audio/transcriptions',
                files=files,
                data=data
            )
            response.raise_for_status()
            return response.json()['text']
    
    def transcribe_bytes(self, audio_bytes: bytes, language: str = "en") -> str:
        """Transcribe audio bytes to text."""
        files = {'file': ('audio.wav', audio_bytes, 'audio/wav')}
        data = {
            'model': 'small',
            'language': language,
            'response_format': 'json'
        }
        response = requests.post(
            f'{self.base_url}/audio/transcriptions',
            files=files,
            data=data
        )
        response.raise_for_status()
        return response.json()['text']

# Usage
stt = LocalWhisperSTT()
text = stt.transcribe('recording.wav')
print(f"Transcription: {text}")
```

### With LangChain Chains

```python
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate

# Create transcription utility
stt = LocalWhisperSTT()

# Use in a chain
template = """
Transcribe the following audio and summarize:
Audio: {audio_path}

Transcription: {transcription}

Summary:
"""

prompt = PromptTemplate(
    input_variables=["audio_path", "transcription"],
    template=template
)

# Execute
audio_path = "meeting.wav"
transcription = stt.transcribe(audio_path)
chain = LLMChain(llm=your_llm, prompt=prompt)
result = chain.run(audio_path=audio_path, transcription=transcription)
```

---

## Custom Python Application

### Basic Client

```python
#!/usr/bin/env python3
"""
Whisper STT Client Example
Transcribe audio files using local Whisper API.
"""

import requests
from pathlib import Path
from typing import Optional

class WhisperSTTClient:
    """Client for local Whisper STT API."""
    
    def __init__(self, base_url: str = "http://localhost:7861"):
        self.base_url = base_url
    
    def transcribe(
        self,
        audio_path: str,
        language: Optional[str] = None,
        response_format: str = "json"
    ) -> dict | str:
        """
        Transcribe audio file.
        
        Args:
            audio_path: Path to audio file
            language: Language code (None for auto-detect)
            response_format: 'json' or 'text'
        
        Returns:
            Transcription result
        """
        url = f"{self.base_url}/v1/audio/transcriptions"
        
        with open(audio_path, 'rb') as f:
            files = {'file': f}
            data = {
                'model': 'small',
                'language': language or '',
                'response_format': response_format
            }
            
            response = requests.post(url, files=files, data=data)
            response.raise_for_status()
            
            if response_format == 'json':
                return response.json()
            return response.text
    
    def health_check(self) -> dict:
        """Check server health."""
        response = requests.get(f"{self.base_url}/health")
        response.raise_for_status()
        return response.json()
    
    def is_ready(self) -> bool:
        """Check if server is ready."""
        try:
            response = requests.get(f"{self.base_url}/ready")
            return response.status_code == 200
        except requests.exceptions.RequestException:
            return False


# Example usage
if __name__ == "__main__":
    client = WhisperSTTClient()
    
    # Check server status
    print("Server health:", client.health_check())
    print("Server ready:", client.is_ready())
    
    # Transcribe audio
    result = client.transcribe("recording.wav", language="en")
    print(f"Transcription: {result['text']}")
```

### Async Client

```python
import aiohttp
import asyncio
from typing import Optional

class AsyncWhisperSTTClient:
    """Async client for local Whisper STT API."""
    
    def __init__(self, base_url: str = "http://localhost:7861"):
        self.base_url = base_url
        self.session: Optional[aiohttp.ClientSession] = None
    
    async def _get_session(self) -> aiohttp.ClientSession:
        if self.session is None:
            self.session = aiohttp.ClientSession()
        return self.session
    
    async def close(self):
        if self.session:
            await self.session.close()
            self.session = None
    
    async def transcribe(
        self,
        audio_path: str,
        language: Optional[str] = None
    ) -> str:
        """Transcribe audio file asynchronously."""
        session = await self._get_session()
        
        url = f"{self.base_url}/v1/audio/transcriptions"
        
        with open(audio_path, 'rb') as f:
            data = aiohttp.FormData()
            data.add_field('file', f, filename='audio.wav', content_type='audio/wav')
            data.add_field('model', 'small')
            data.add_field('language', language or '')
            data.add_field('response_format', 'json')
            
            async with session.post(url, data=data) as response:
                response.raise_for_status()
                result = await response.json()
                return result['text']


# Example usage
async def main():
    client = AsyncWhisperSTTClient()
    try:
        text = await client.transcribe("recording.wav")
        print(f"Transcription: {text}")
    finally:
        await client.close()

asyncio.run(main())
```

---

## Custom Node.js Application

### Basic Client

```javascript
/**
 * Whisper STT Client for Node.js
 * Transcribe audio using local Whisper API
 */

const FormData = require('form-data');
const fs = require('fs');
const axios = require('axios');

class WhisperSTTClient {
  constructor(baseURL = 'http://localhost:7861') {
    this.baseURL = baseURL;
  }

  /**
   * Transcribe audio file
   * @param {string} audioPath - Path to audio file
   * @param {string} [language] - Language code (optional)
   * @returns {Promise<string>} Transcribed text
   */
  async transcribe(audioPath, language = null) {
    const form = new FormData();
    form.append('file', fs.createReadStream(audioPath));
    form.append('model', 'small');
    form.append('language', language || '');
    form.append('response_format', 'json');

    const response = await axios.post(
      `${this.baseURL}/v1/audio/transcriptions`,
      form,
      { headers: form.getHeaders() }
    );

    return response.data.text;
  }

  /**
   * Check server health
   * @returns {Promise<object>} Health status
   */
  async healthCheck() {
    const response = await axios.get(`${this.baseURL}/health`);
    return response.data;
  }

  /**
   * Check if server is ready
   * @returns {Promise<boolean>} Ready status
   */
  async isReady() {
    try {
      const response = await axios.get(`${this.baseURL}/ready`);
      return response.status === 200;
    } catch {
      return false;
    }
  }
}

// Example usage
async function main() {
  const client = new WhisperSTTClient();
  
  console.log('Server health:', await client.healthCheck());
  console.log('Server ready:', await client.isReady());
  
  const text = await client.transcribe('recording.wav', 'en');
  console.log(`Transcription: ${text}`);
}

main().catch(console.error);
```

### TypeScript Version

```typescript
import FormData from 'form-data';
import fs from 'fs';
import axios, { AxiosInstance } from 'axios';

interface TranscriptionOptions {
  language?: string;
  responseFormat?: 'json' | 'text';
}

interface HealthStatus {
  status: string;
  model: string;
  device: string;
  compute_type: string;
}

class WhisperSTTClient {
  private client: AxiosInstance;

  constructor(baseURL: string = 'http://localhost:7861') {
    this.client = axios.create({
      baseURL,
      timeout: 120000, // 2 minute timeout for transcription
    });
  }

  async transcribe(
    audioPath: string,
    options: TranscriptionOptions = {}
  ): Promise<string> {
    const form = new FormData();
    form.append('file', fs.createReadStream(audioPath));
    form.append('model', 'small');
    form.append('language', options.language || '');
    form.append('response_format', options.responseFormat || 'json');

    const response = await this.client.post(
      '/v1/audio/transcriptions',
      form,
      { headers: form.getHeaders() }
    );

    return options.responseFormat === 'text' 
      ? response.data 
      : response.data.text;
  }

  async healthCheck(): Promise<HealthStatus> {
    const response = await this.client.get('/health');
    return response.data;
  }

  async isReady(): Promise<boolean> {
    try {
      const response = await this.client.get('/ready');
      return response.status === 200;
    } catch {
      return false;
    }
  }
}

export { WhisperSTTClient };
```

---

## REST API Reference

### Base URL

```
http://localhost:7861/v1
```

### Endpoints

#### POST /v1/audio/transcriptions

Transcribe audio to text.

**Request:**
- Method: POST
- Content-Type: multipart/form-data

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| file | file | Yes | - | Audio file (WAV, MP3, FLAC, M4A, WEBM) |
| model | string | No | small | Model name (for compatibility) |
| language | string | No | null | Language code (auto-detect if null) |
| response_format | string | No | json | Response format: "json" or "text" |

**Response (JSON):**
```json
{
  "text": "And so my fellow Americans, ask not what your country can do for you..."
}
```

**Response (Text):**
```
And so my fellow Americans, ask not what your country can do for you...
```

**Error Response:**
```json
{
  "error": "Error message here"
}
```

**HTTP Status Codes:**
- 200: Success
- 400: Bad request (invalid parameters)
- 500: Server error (model loading failed, etc.)

---

#### GET /v1/models

List available models.

**Response:**
```json
{
  "object": "list",
  "data": [
    {
      "id": "small",
      "object": "model",
      "created": 1771538436,
      "owned_by": "openai"
    }
  ]
}
```

---

#### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "model": "small",
  "device": "cuda",
  "compute_type": "float16"
}
```

---

#### GET /ready

Readiness check.

**Response (Ready):**
```json
{
  "status": "ready"
}
```

**Response (Loading):**
```json
{
  "status": "loading"
}
```
(HTTP 503)

---

## Language Codes

Supported language codes for the `language` parameter:

| Code | Language | Code | Language |
|------|----------|------|----------|
| en | English | es | Spanish |
| fr | French | de | German |
| it | Italian | pt | Portuguese |
| ru | Russian | zh | Chinese |
| ja | Japanese | ko | Korean |
| hi | Hindi | ar | Arabic |
| tr | Turkish | pl | Polish |
| nl | Dutch | sv | Swedish |

Full list: [Whisper Language Support](https://github.com/openai/whisper/blob/main/whisper/tokenizer.py)

---

## Troubleshooting

### Connection Refused

```bash
# Check if server is running
curl http://localhost:7861/health

# Check server process
ps aux | grep whisper-api

# Start server
~/.local/bin/hypr-stt start-server
```

### Timeout Errors

Increase timeout in your client:
```python
# Python
response = requests.post(url, files=files, data=data, timeout=300)
```

```javascript
// Node.js
const client = axios.create({ baseURL, timeout: 300000 });
```

### CUDA Out of Memory

```bash
# Stop server to free VRAM
~/.local/bin/hypr-stt stop-server

# Restart with CPU
WHISPER_DEVICE=cpu ~/.local/bin/whisper-api-server
```

---

## Support

For issues or questions:
1. Check server logs: `journalctl --user -u whisper-api.service -f`
2. Verify API endpoint: `curl http://localhost:7861/health`
3. Test with sample audio: See main README.md
