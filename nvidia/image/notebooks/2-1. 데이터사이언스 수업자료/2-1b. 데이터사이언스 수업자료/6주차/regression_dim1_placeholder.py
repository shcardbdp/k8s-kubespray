import tensorflow as tf

x_data = [[1], [2], [3]]
y_data = [[1], [2], [3]]
X = tf.placeholder(tf.float32, shape=[None, 1])
Y = tf.placeholder(tf.float32, shape=[None, 1])
W = tf.Variable(tf.random_normal([1]))
b = tf.Variable(tf.random_normal([1]))

model = X*W+b
cost = tf.reduce_mean(tf.square(model - Y))
train = tf.train.GradientDescentOptimizer(0.01).minimize(cost)

with tf.Session() as sess:
	sess.run(tf.global_variables_initializer())
	# Training
	for step in range(2001):
		c, W_, b_, _ = sess.run([cost, W, b, train], feed_dict={X: x_data, Y: y_data})
		print(step, c, W_, b_)
	# Testing:
	print(sess.run(model, feed_dict={X: [[4]]}))