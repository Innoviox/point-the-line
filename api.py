from fastapi import FastAPI
from openai import OpenAI

app = FastAPI()

openapikey = open("openapikey").read()
client = OpenAI(api_key=openapikey)

@app.get("/adjectives/{base64_image}")
async def 
    prompt = (
        "Use exactly ten adjectives and no more words to describe the common building in these images. "
        "Describe the size shape color style feel texture material appearance design and architecture. "
        "Label each adjective by what it describes."
    )


    response = client.chat.completions.create(
      model="gpt-4-vision-preview",
      messages=[
        {
          "role": "user",
          "content": [
            {"type": "text", "text": prompt},
            {
              "type": "image_url",
              "image_url": {
                  "url": f"data:image/jpeg;base64,{base64_image}",
                  "detail": "low"
              },
            },
          ],
        }
      ],
      max_tokens=300,
    )

    return response.choices[0]
    
