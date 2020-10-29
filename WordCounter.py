'''
A counter turns a sequence of values into a defaultdict(int)-like object mapping keys to counts. we will use 
it to create Histogram
'''
from collections import Counter       #Import Counter To Count Numbers 
import random                         # Genrate Random Number
n = 100                               # n = Total Number of Random Genrated Numbers 
doc = []
for i in range(n):                    
	nums = random.randint(10,50)      # Genrate n number Between 10-50
	doc.append(nums)
print(doc) 							  # Print List Of Random Genrated Numbers
word_counts = Counter(doc)
for word, count in word_counts.most_common(10):  # Count Most Common 10 Numbers
	print('The Number %d Comes %d times '  %(word,count))

#print(word_counts.most_common(10))
