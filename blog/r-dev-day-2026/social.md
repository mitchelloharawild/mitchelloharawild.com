🎉 I just made my first-ever contribution to R itself — fixing a bug in `seq.int(along.with = NULL)`. Try it yourself (the result is absurd!) 🐛

I first spotted the bug while developing the vecvec package (https://pkg.mitchelloharawild.com/vecvec/). Instead of returning a 0 length vector, it produced over 100 trillion numbers! 🤯 So I brought it along to R Dev Day in Warsaw, where Balasubramanian Narasimhan and Henrik Bengtsson helped me track it down. The fix was simple, making 7 characters lowercase - but the debugging process was a lot of fun!

📖 I wrote about it on my blog here: https://mitchelloharawild.com/blog/r-dev-day-2026/

Big thanks to Heather Turner and Ella Kaye for organising the day, and everyone else at R Dev Day for the support. If you use R and have ever considered contributing back, do it! 🙌

#rstats #opensource #useR2026