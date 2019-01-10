from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

import tensorflow as tf
import numpy as np

num_training_images = 5000 # maximum: 55000
num_testing_images = 200 # maximum: 5000
num_pixels_MNIST = 28*28
pixel_train, onehot_train = mnist.train.next_batch(num_training_images) # Train
pixel_test,  onehot_test  = mnist.test.next_batch(num_testing_images) # Test, # num_testing_images == len(pixel_test)
#print('pixel_train:', pixel_train.shape) # (5000x784)
#print('onehot_train:', onehot_train.shape) # (5000x10)
#print('pixel_test:', pixel_test.shape) # (200x784)
#print('onehot_test:', onehot_test.shape) # (200x10)

TRAIN = tf.placeholder("float", [None, num_pixels_MNIST]) # None: batch size, 784: num of images
TEST  = tf.placeholder("float", [num_pixels_MNIST]) # 784: num of images

# kNN with k=1
distance = tf.reduce_sum(tf.abs(tf.add(TRAIN, tf.negative(TEST))), reduction_indices=1) # print(distance), 5000-by-1
kNN_01 = tf.argmin(distance, 0)
accuracy = 0.

with tf.Session() as sess:
	sess.run(tf.global_variables_initializer())
	for i in range(num_testing_images):
		knn_index_01 = sess.run(kNN_01, feed_dict={TRAIN: pixel_train, TEST: pixel_test[i,:]}) 
		print("Test: ", i, "Prediction: ", np.argmax(onehot_train[knn_index_01]), "Actual: ", np.argmax(onehot_test[i]))
		if np.argmax(onehot_train[knn_index_01]) == np.argmax(onehot_test[i]):
			accuracy += 1./num_testing_images
	print("Accuracy: ", accuracy*100 ,"percentage")
