
# ��¼
f_renren_login <- function(name="****", pwd="****"){
memory.limit(4000)
require(RCurl)

myH <- c(
"User-Agent"="Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.2.12) Gecko/20101026 Firefox/3.6.12",
"Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
"Accept-Language"="zh-cn,zh;q=0.5",
#"Accept-Encoding"="gzip,deflate",
"Accept-Charset"="GB2312,utf-8;q=0.7,*;q=0.7",
"Keep-Alive"="115",
"Connection"="keep-alive",
#"Host"="status.renren.com",
"Content-Type"="application/x-www-form-urlencoded; charset=UTF-8",
#"Content-Length"=as.character(nchar(xx)*2+1),
"Pragma"="no-cache",
#"Referer"="http://status.renren.com/ajaxproxy.htm",
"Cache-Control"="no-cache"
)
d <- debugGatherer()
cH <- getCurlHandle(debugfunction=d$update, verbose=T, ssl.verifyhost=F, 
ssl.verifypeer=F, followlocation=T, cookiefile="cc.txt")
pinfo <- c(
"email"=name,
"password"=pwd,
"origURL"="http://www.renren.com/Home.do",
"domain"="renren.com"
)
pinfo <- iconv(pinfo, from="GB18030", to="UTF-8")
ttt <- postForm("http://passport.renren.com/PLogin.do", httpheader=myH,
.params=pinfo, curl=cH, style="post")
getCurlInfo(cH)[["cookielist"]]
return(cH)
}


# ��ȡ״̬
f_renren_status <- function(cH=ch0, N=200, readlist=F, hisname='���ݲ�'){
memory.limit(4000)
require(RCurl)

load('MyFriendList.RData')

if(readlist){
h <- getURL("http://www.renren.com", curl=cH, .encoding="gbk")
write(h, "temp.txt")
hh <- readLines("temp.txt", encoding="UTF-8")
file.remove("temp.txt")
rm(h)

hh2 <- hh[grep("user : ", hh)]
hh2 <- gsub("[^0-9]", "", hh2)
uid <- hh2
# uid
# "41021031"

# �������ֺ�ID�Ķ�Ӧ��
thisurl <- paste("http://friend.renren.com/GetFriendList.do?curpage=0&id=", uid, sep="")
h <- getURL(thisurl, curl=cH, .encoding="gbk")
write(h, "temp.txt")
hh <- readLines("temp.txt", encoding="UTF-8")
file.remove("temp.txt")
rm(h)

friend <- data.frame(u1=NULL, id1=NULL)

# ����ҳ
imax <- 0
if(length(grep("���ҳ", hh)) > 0){
imax <- strsplit(hh[grep("���ҳ", hh)[1]], "curpage=")[[1]][2]
imax <- strsplit(imax, "&amp")[[1]][1]
}
if(length(grep("���ҳ", hh)) == 0 & length(grep("��һҳ", hh)) > 0){
nextpage <- grep("��һҳ", hh)[1]
hh_pages <- hh[(nextpage-30) : (nextpage - 1)]
lastpage <- hh_pages[max(grep("curpage=", hh_pages))]
imax <- strsplit(lastpage, "curpage=")[[1]][2]
imax <- strsplit(imax, "&amp")[[1]][1]
}
imax <- as.numeric(imax)

# �ҵ�����
u0 <- strsplit(hh[grep("�ĺ���</title>", hh)], "�ĺ���</title>")[[1]][1]
u0 <- strsplit(u0, "������ - ")[[1]][2]

# ����ÿ�����ѵ����֡�ÿ�����Ѷ����Լ�ʱ���졣����Ϊʲô�ˣ��е�ֻ�С�����к���
ii <- grep("��ʱ����", hh)
if(length(ii) == 0){
hh <- hh[grep("����к�", hh)[1]]
ff <- strsplit(hh, "event,'")[[1]][2]
ff <- strsplit(ff, "'[)]")[[1]][1]
ff1 <- strsplit(ff, "','")[[1]][1]
ff2 <- strsplit(ff, "','")[[1]][2]
friendnew <- data.frame(u1=ff2, id1=ff1)
friend <- rbind(friend, friendnew)
}
if(length(ii) >= 1){
hh <- hh[ii]
for(iii in 1:length(ii)){
ff <- strsplit(hh[iii], ":talkto[(]")[[1]][2]
ff <- strsplit(ff, "'[)];return false")[[1]][1]
ff1 <- strsplit(ff, ", '")[[1]][1]
ff2 <- strsplit(ff, ", '")[[1]][2]
friendnew <- data.frame(u1=ff2, id1=ff1)
friend <- rbind(friend, friendnew)
}
}

# ҳ��ѭ��
if(imax >= 1){
for(pagei in 1:imax){
thisurl <- paste("http://friend.renren.com/GetFriendList.do?curpage=", pagei, "&id=", uid, sep="")
h <- getURL(thisurl, curl=cH, .encoding="gbk")
write(h, "temp.txt")
hh <- readLines("temp.txt", encoding="UTF-8")
file.remove("temp.txt")
rm(h)

# ����ÿ�����ѵ����֡�ÿ�����Ѷ����Լ�ʱ���졣����Ϊʲô�ˣ��е�ֻ�С�����к���
ii <- grep("��ʱ����", hh)
if(length(ii) == 0){
hh <- hh[grep("����к�", hh)[1]]
ff <- strsplit(hh, "event,'")[[1]][2]
ff <- strsplit(ff, "'[)]")[[1]][1]
ff1 <- strsplit(ff, "','")[[1]][1]
ff2 <- strsplit(ff, "','")[[1]][2]
friendnew <- data.frame(u1=ff2, id1=ff1)
friend <- rbind(friend, friendnew)
}
if(length(ii) >= 1){
hh <- hh[ii]
for(iii in 1:length(ii)){
ff <- strsplit(hh[iii], ":talkto[(]")[[1]][2]
ff <- strsplit(ff, "'[)];return false")[[1]][1]
ff1 <- strsplit(ff, ", '")[[1]][1]
ff2 <- strsplit(ff, ", '")[[1]][2]
friendnew <- data.frame(u1=ff2, id1=ff1)
friend <- rbind(friend, friendnew)
}
}
}
}
# �ҵ����ֺ�ID
friend <- rbind(friend, data.frame(u1=u0, id1=uid))
}
hisid <- as.character(friend$id1[friend$u1 == hisname])

pg <- 0
thisurl <- paste("http://status.renren.com/GetSomeomeDoingList.do?userId=", hisid, "&curpage=", pg, sep="")
h <- getURL(thisurl, curl=cH, .encoding="gbk")
write(h, "temp.txt")
hh <- readLines("temp.txt", encoding="UTF-8")
file.remove("temp.txt")
rm(h)
h1 <- strsplit(hh, '\"count\":')[[1]][2]
h2 <- as.numeric(strsplit(h1, ',\"')[[1]][1])

pages <- ceiling(min(N, h2)/20)

h_status <- c()

for (pg in 0:pages){

thisurl <- paste("http://status.renren.com/GetSomeomeDoingList.do?userId=", hisid, "&curpage=", pg, sep="")
h <- getURL(thisurl, curl=cH, .encoding="gbk")
write(h, "temp.txt")
hh <- readLines("temp.txt", encoding="UTF-8")
file.remove("temp.txt")
rm(h)

while(length(grep('[\u4e00-\u9fff]', hh)) <= 0){
thisurl <- paste("http://status.renren.com/GetSomeomeDoingList.do?userId=", hisid, "&curpage=", pg, sep="")
h <- getURL(thisurl, curl=cH, .encoding="gbk")
write(h, "temp.txt")
hh <- readLines("temp.txt", encoding="UTF-8")
file.remove("temp.txt")
rm(h)
}

h1 <- strsplit(hh, '"content":"')
h2 <- strsplit(h1[[1]], '","')
h3 <- unlist(lapply(h2, FUN=function(r){r[1]}))[-1]
# h4 <- iconv(h3, 'UTF-8', 'UTF-8')
# require(Unicode)
# getexpr <- function(str, greg){
# substring(str, greg+2, greg + attr(greg, 'match.length') - 1)
# }
# h_reg <- mapply(getexpr, h3[11], gregexpr('\\\\u.{4}', h3[11]))
# h_exp <- sapply(h_reg, FUN=function(r){paste(u_char_inspect(r)$Char, collapse='')})
h_exp <- h3
h_status <- c(h_status, h_exp)
gc()
print(length(h_status))
}
names(h_status) <- NULL
return(h_status)
}


# ����ָ���ҿ����ø��˴�Ƶ�빫����Ƶ���Ƚϣ���ɸѡ�ؼ��ʡ����������������ɴ��Ƶĺ�����
f_renren_wordcloud <- function(renren_data=status_1000_0, hisname='���ݲ�'){
require(wordcloud)
require(rmmseg4j)

# ȥ��ת������������
getexpr2 <- function(str, greg){
substring(str, 1, greg[1]-1)
}
h_exp1 <- grep('ת��', renren_data, value=T, invert=T)
h_exp2 <- grep('ת��', renren_data, value=T, invert=F)
h_exp3 <- mapply(getexpr2, h_exp2, gregexpr('ת��', h_exp2))
renren_data <- c(h_exp1, h_exp3)
names(renren_data) <- NULL
# ȥ�����鼰�������ַ�
renren_data <- gsub(' alt=\'[^\']+\'', '', renren_data)
renren_data <- gsub('[^\u4e00-\u9fff ����]', '', renren_data)

# �ִ�
f_cut <- function(x){
unlist(strsplit(mmseg4j(x), ' '))
}
words <- unlist(mapply(f_cut, renren_data))
names(words) <- NULL

# ͳ�ƴ�Ƶ
words_freq <- sort(table(words), dec=T)
words_names <- names(words_freq)
words_length <- nchar(words_names)

# �����ѹ�ʵ���ҵĴ�Ƶ�ļ�
SogouLabDic <- read.table('SogouLabDic.dic', fill=T, head=F)
names(SogouLabDic)[1] <- 'words_names'

words_df <- data.frame(words_names=words_names, words_freq=words_freq, words_length=words_length)
# ֻ���������ֵĴʣ���һ�㡣����
words_df <- words_df[words_df$words_length %in% c(2,3), ]
SogouLabDic0 <- SogouLabDic[SogouLabDic[,1] %in% words_df$words_names, ]

words_df2 <- merge (words_df, SogouLabDic0, by='words_names', all.x=T)
# ����ɸѡ���ʺͶ��ʡ������ƺ�û�б�Ҫ����Ϊ���ݴʸ���ʲô��Ҳ�ܹ������ôʷ����
words_df2 <- words_df2[grep('^[NV],$',words_df2$V3), ]

# ƥ�䲻�����ӵ�
words_df3 <- words_df2[!is.na(words_df2$V2), ]
words_df3$words_freq2 <- words_df3$words_freq * log(max(words_df3$V2)/words_df3$V2)

words_df3 <- words_df3[order(-words_df3$words_freq2), ][1:50, ]
# words_df3$words_rank <- ceiling(rank(words_df3$words_freq2))
# words_df3$words_rank <- ceiling(words_df3$words_rank*50/max(words_df3$words_rank))
wd_freq2 <- words_df3$words_freq2
freq_median <- median(wd_freq2)
freq_beta <- max(wd_freq2)/min(wd_freq2)

# �����ƣ������ò�ƶ�����֧�ֲ��Ǻܺã�
png(paste('renren_wordcloud_', Sys.Date(), '_', hisname, '.png', sep=''),width=500,height=500)
par(mar=c(0,0,0,0))
wordcloud(words_df3$words_names, words_df3$words_freq2, min.freq=0,
scale=c(3.53+0.65*freq_beta,1), 
# scale=c(4.366+0.009675*freq_median+0.411033*freq_beta,1), 
max.words=50, random.order=F, colors=terrain.colors(50,1))
dev.off()
}


