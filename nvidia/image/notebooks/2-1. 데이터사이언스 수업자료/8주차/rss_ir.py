import feedparser
from newspaper import Article
from konlpy.tag import Komoran
from konlpy.tag import Okt
from collections import Counter
from operator import eq
import math
import numpy as np

komoran = Komoran()

urls = ("https://rss.joins.com/sonagi/joins_sonagi_sports_list.xml"
	#, "https://rss.joins.com/sonagi/joins_sonagi_star_list.xml"
	#, "https://rss.joins.com/sonagi/joins_sonagi_life_list.xml"
	, None)

def crawl_rss(urls):
	arr_rss = []
	for url in urls:
		print("[Crawl RSS] ",url)
		parse_rss = feedparser.parse(url)
		for p in parse_rss.entries:
			arr_rss.append({'title':p.title, 'link':p.link})
	return arr_rss

def crawl_article(url, language='ko'):
	print("[Crawl Article] ",url)
	var_article = Article(url, language=language)
	var_article.download()
	var_article.parse()
	return var_article.title, var_article.text

def get_tags(text, ntags=50):
	spliter = Okt()
	num_unique_words = 0
	num_most_freq = 0
	nouns = spliter.nouns(text)
	count = Counter(nouns)
	return_list = []
	for n, c in count.most_common(ntags):
		temp = {'tag': n, 'count': c}
		return_list.append(temp)
		num_unique_words = num_unique_words+1
		if num_unique_words == 1:
			num_most_freq = c
	return num_unique_words, num_most_freq, return_list

def TF(request, most_freq, tag):
	return 0.5 + 0.5*Howmanywords(request, tag)/most_freq

def Howmanywords(request, tag):
	noWords = 0
	for n in tag:
		noun = n['tag']
		count = n['count']
		if eq(noun, request):
			return count
	return noWords

def HowManyWords(query, tags):
	noWords = 0
	for n in tags:
		noun = n['tag']
		count = n['count']
		if eq(query, noun):
			return count
	return noWords

def TF(request, most_freq,tag):
	return 0.5+0.5*HowManyWords(request,tag)/most_freq
    
def main():
	article_list = crawl_rss(urls)
	for article in article_list:
		_, text = crawl_article(article['link'])
		article['text'] = text

	print('[ Parsing Title ]')
	noun_title = [komoran.nouns(a['title']) for a in article_list]
	print(noun_title)

	query = input()
	print('[ Parsing Query ]')
	noun_query = [komoran.nouns(query)]
	print(noun_query)

	print('[Parsing Text]')
	noun_text = []
	for a in article_list:
		num_unique_words, num_most_freq, tags = get_tags(a['text'])
		noun_text.append({'num_unique_words': num_unique_words, 'num_most_freq': num_most_freq, 'tags': tags})
	print(noun_text)

	tf_idf_title = []
	tf_idf_mean = []
	tf_idf_query = []
	tf_idf_mean_query = []
	tag_list = [a['tags'] for a in noun_text]
	for i, nouns in enumerate(noun_title):
		tfs = [TF(req,noun_text[i]['num_most_freq'], noun_text[i]['tags']) for req in nouns]
		_tfidf = [tfs[j] for j,n in enumerate(nouns)]
		tf_idf_title.append(_tfidf)
		tf_idf_mean.append(np.mean(_tfidf))

		for k, nouns_query in enumerate(noun_query):
			tfs_query = [TF(req,noun_text[i]['num_most_freq'], noun_text[i]['tags']) for req in nouns_query]
			_tfidf_query = [tfs_query[j] for j,n in enumerate(nouns_query)]
			tf_idf_query.append(_tfidf_query)
			tf_idf_mean_query.append(np.mean(_tfidf_query))

	for i,e in enumerate(tf_idf_mean):
		print("TF-IDF: ", e, ", title: ", article_list[i]['title'])
	for i,e in enumerate(tf_idf_mean_query):
		print("TF-IDF-Query: ", e, ", title: ", article_list[i]['title'])

	print("====================")
	print( '[TF,title]')
	print( tf_idf_title)
	print("====================")
	print( '[TF,query]')
	print( tf_idf_query)
        
if __name__ == "__main__":
	main()
