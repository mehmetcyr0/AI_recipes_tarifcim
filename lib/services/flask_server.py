from flask import Flask, request, jsonify
import google.generativeai as genai
import os

app = Flask(__name__)

# Configure the Gemini API key directly
API_KEY = "YOUR_GEMINI_API_KEY"
genai.configure(api_key=API_KEY)

@app.route('/api/generate', methods=['POST'])
def generate_response():
    try:
        data = request.json
        
        # Extract parameters from request
        user_prompt = data.get('user_prompt')
        system_prompt = data.get('system_prompt')
        model_name = data.get('model', 'gemini-2.0-pro')
        temperature = data.get('temperature', 0.7)
        max_tokens = data.get('max_tokens', 1024)
        
        # Validate required parameters
        if not user_prompt:
            return jsonify({"success": False, "error": "Missing user prompt"}), 400
            
        # Configure the model
        model = genai.GenerativeModel(
            model_name=model_name,
            generation_config={
                "temperature": temperature,
                "max_output_tokens": max_tokens,
                "top_p": 0.95,
                "top_k": 40,
            }
        )
        
        # Generate content
        chat = model.start_chat(history=[])
        response = chat.send_message(f"{system_prompt}\n\nKullanıcı: {user_prompt}")
        
        # Return the response
        return jsonify({
            "success": True,
            "response": response.text,
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
