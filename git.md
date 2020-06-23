# 1.上传本地文件到git

```
mkdir testapp 
cd testapp 
```

### 2.通过命令git init把这个文件夹变成Git可管理的仓库
``` 
git init
```

### 3.这时候你就可以把你的项目粘贴到这个本地Git仓库里面（粘贴后你可以通过git status来查看你当前的状态），然后通过git add把项目添加到仓库（或git add .把该目录下的所有文件添加到仓库，注意点是用空格隔开的）。在这个过程中你其实可以一直使用git status来查看你当前的状态。如果文件内有东西会出现红色的字，不是绿色，这不是错误。

```
git status
```

### 4.这里提示你虽然把项目粘贴过来了，但还没有add到Git仓库上，然后我们通过git add .把刚才复制过来的项目全部添加到仓库上。

```
git add .
```

### 5. 用git commit -m "日志" 把项目提交到仓库。

```
git commit -m '日志'
```

### 6.在Github上创建一个Git仓库


### 7.在Github上创建好Git仓库之后我们就可以和本地仓库进行关联了，根据创建好的Git仓库页面的提示，可以在本地testapp仓库的命令行输入：
```
git remote add origin https://github.com/lqs
```

### 8.通过查看提示信息，我发现，是因为本地仓库和远程仓库的文件不一致所致，也就是说，github允许你本地仓库有的东西，远程仓库里没有，但不允许远程仓库有的东西，你本地仓库没有。问题找到了，解决办法就很简单了，那就是在push之前先同步一下本地仓库与远程仓库的文件。使用以下命令

```
git pull --rebase origin master
```

### 8.关联好之后我们就可以把本地库的所有内容推送到远程仓库（也就是Github）
```
git push origin master
```
