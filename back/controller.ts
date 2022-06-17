import fs from 'fs'
import path from 'path'
class controller
{
    async getFragment(_req: any, res: any){
        let data
        fs.readFile(
            '../fs.glsl', 'utf-8', (err, content)=>{
                try{
                    // data = content
                    res.status(200).json(content)
                }catch(e){
                    console.log(err)
                    res.status(400).json('Ошибка чтения файла')
                }
            }
        )
        
    }
    async getVertex(_req: any, res: any){
        let data
        fs.readFile(
            '../vs.glsl', 'utf-8', (err, content)=>{
                try{
                    // data = content
                    res.status(200).json(content)
                }catch(e){
                    console.log(err)
                    res.status(400).json('Ошибка чтения файла')
                }
            }
        )
    }
    async home(req: any, res:any){

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

        // res.sendFile(path.join(pa + '/script.js'))
        res.sendFile(path.join(pa + '/index.html'))
        // res.sen
    }
}

export default new controller()