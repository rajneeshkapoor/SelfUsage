import boto3
s3 = boto3.resource('s3')
for bucket in s3.buckets.all():
	print("\n$$$$$$\n")
	print (bucket.name)
    	print("\n####\n")
	a=0
	for item in bucket.objects.all():
		print(item.key)
		a+=1
		if(a>=3):
			break
