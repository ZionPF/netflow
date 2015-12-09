from PIL import Image
img = Image.new("L",(20,255),"white")
print img.size[0]
print img.size[1]
pixels = img.load()
'''
for i in range(img.size[0]):
	for j in range(img.size[1]):
		pixels[i,j] = i
'''
img.save("test.png")
