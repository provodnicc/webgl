import express from 'express'
import router from './router'
import path from 'path'

const app = express()

app.use(express.json())

app.use(router)
app.use('/script.js',(_req:any,res:any,_next:any)=>{
    let dir = __dirname.split('/')
        let pa = ''
        var i = 0 
        console.log(dir)
        for (let d in dir){
            i++
            
            if(i != dir.length-1){
                pa += '/' + dir[i]
                
            }else{
                break
            }
                
        }
    res.type('text/javascript');
    // res.writeHead('content-type', 'text/javascript')
    res.sendFile(path.join(pa + '/script.js'))

})
app.use('/index.css',(_req:any,res:any,_next:any)=>{
    let dir = __dirname.split('/')
        let pa = ''
        var i = 0 
        console.log(dir)
        for (let d in dir){
            i++
            
            if(i != dir.length-1){
                pa += '/' + dir[i]
                
            }else{
                break
            }
                
        }
    res.type('text/css');
    // res.writeHead('content-type', 'text/javascript')
    res.sendFile(path.join(pa + '/script.js'))

})


app.listen(5000, ()=>{})