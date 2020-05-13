//
//  Contour.swift
//  FileFlatform
//
//  Created by SUNG KIM on 2020/04/30.
//  Copyright © 2020 mcsco. All rights reserved.
//
import Foundation

private var m_dContourPointX: Array<Double> = []
private var m_dContourPointY: Array<Double> = []
private var m_nContourPointNum: Int = 0
private var m_nLevel: Int = 0
private var WIDTH: Int = 0
private var HEIGHT: Int = 0
private let LEVEL_MAX = 11

private var m_sData : Array<Array<Int>> = []
private var m_nPointVel : Array<Array<Int>> = []
private var m_dContourData : Array<Array<Int>> = []
private var m_dBoxedContourData : Array<Array<Int>> = []

private var m_nX : Int = 0
private var m_nY : Int = 0

var m_sMinLevel : Int = 99

class Contours {
  var x_size: Int
  var y_size: Int
  
  init(x_size: Int, y_size: Int) {
    self.x_size = x_size
    self.y_size = y_size
    m_nLevel = 0
    WIDTH = x_size + 1
    HEIGHT = y_size + 1
    m_nX = x_size
    m_nY = y_size
    
    m_dContourPointX = Array(repeating: 0.0, count: 500)
    m_dContourPointY = Array(repeating: 0.0, count: 500)
    m_sData = Array(repeating: Array(repeating: 32767, count: WIDTH+1), count: HEIGHT+1)
    m_nPointVel = Array(repeating: Array(repeating: -13108, count: WIDTH+1), count: HEIGHT+1)
    m_dContourData = Array(repeating: Array(repeating: 0, count: WIDTH), count: HEIGHT)
    m_dBoxedContourData = Array(repeating: Array(repeating: 0, count: WIDTH+2), count: HEIGHT+2)
  }
  
  func drawContour(ac_datas: Array<String>) {
    //draw_context = context
    
    var y_index = 0
    var x_index = 0
    
    
    for i in ac_datas.indices {
      if(i != 0 && i % x_size == 0) {
        y_index = y_index+1
        x_index = 0
      }
      m_sData[y_index][x_index] = Int(ac_datas[i]) ?? 0
      x_index = x_index+1
    }
    
    fillVelocityArray()
    
    let map = ContourMap()
    map.generateLevels(min: 0.0, max: Double(LEVEL_MAX), num: LEVEL_MAX+1)
    map.contour()
    
    map.consolidate()
    map.dump()
  }
  
  
  private func fillVelocityArray() {
    for i in 0..<m_nX {
      for j in 0..<m_nY {
        m_nPointVel[j][i] = m_sData[j][i]
        if(m_nPointVel[j][i] < -500 ) {
          m_nPointVel[j][i] = -500
        } else if(m_nPointVel[j][i] < 600 && m_nPointVel[j][i] > -1) {
          m_nPointVel[j][i] = -1
        }
      }
    }
    
    for i in 0..<m_nY {
      for j in 0..<m_nX {
        m_dContourData[i][j] = getContourLevel(vel: m_nPointVel[i][j])
        m_dBoxedContourData[i+1][j+1] = m_dContourData[i][j]
        
        if(m_sMinLevel>=m_dContourData[i][j]) {
          m_sMinLevel = m_dContourData[i][j]
        }
      }
    }
  }
  
  private func getContourLevel(vel: Int)-> Int
  {
    if(vel < -500)                    {return 0}
    else if(vel < -450 && vel >= -500){return 1}
    else if(vel < -400 && vel >= -450){return 2}
    else if(vel < -350 && vel >= -400){return 3}
    else if(vel < -300 && vel >= -350){return 4}
    else if(vel < -250 && vel >= -300){return 5}
    else if(vel < -200 && vel >= -250){return 6}
    else if(vel < -150 && vel >= -200){return 7}
    else if(vel < -100 && vel >= -150){return 8}
    else if(vel <  -50 && vel >= -100){return 9}
    else {return 10}
  }
}

class ContourMap {
  private var levels: Array<Double> = []
  private var n_levels : Int = 0
  private var contour_level: Array<ContourLevel> = []
  
  func generateLevels(min: Double, max: Double, num: Int) {
    let min = min
    let max = max
    let num = num
    let step : Double = (max-min)/Double((num-1))
    
    n_levels = num
    for i in 0..<num {
      levels.append(min + (step * Double(i)))
    }
  }
  
  func dump() {
    for i in contour_level.indices {
      contour_level[i].dump()
      m_nLevel = i
    }
  }
  
  func contour() {
    var m1: Int
    var m2: Int
    var m3: Int
    var case_value: Int
    
    var dmin: Int
    var dmax: Int
    var x1: Double = 0.0
    var x2: Double = 0.0
    var y1: Double = 0.0
    var y2: Double = 0.0
    
    var h: Array<Double> = Array(repeating: 0.0, count: 5)
    var sh: Array<Int> = Array(repeating: -10, count: 5)
    var xh: Array<Double> = Array(repeating: 0.0, count: 5)
    var yh: Array<Double> = Array(repeating: 0.0, count: 5)
    //===========================================================================
    // The indexing of im and jm should be noted as it has to start from zero
    // unlike the fortran counter part
    //===========================================================================
    let im: Array<Int> = Array(arrayLiteral: 0,1,1,0)
    let jm: Array<Int> = Array(arrayLiteral: 0,0,1,1)
    
    //===========================================================================
    // Note that castab is arranged differently from the FORTRAN code because
    // Fortran and C/C++ arrays are transposed of each other, in this case
    // it is more tricky as castab is in 3 dimension
    //===========================================================================
    let castab: Array<Array<Array<Int>>> =
      Array(arrayLiteral:
        Array(arrayLiteral:
          Array(arrayLiteral: 0,0,8),
          Array(arrayLiteral: 0,2,5),
          Array(arrayLiteral: 7,6,9)),
        Array(arrayLiteral:
          Array(arrayLiteral: 0,3,4),
          Array(arrayLiteral: 1,3,1),
          Array(arrayLiteral: 4,3,0)),
        Array(arrayLiteral:
          Array(arrayLiteral: 9,6,7),
          Array(arrayLiteral: 5,2,0),
          Array(arrayLiteral: 8,0,0)))
    
    for j in (0 ... WIDTH-1).reversed()  {
      for i in 0 ..< HEIGHT+1 {
        var temp1: Int = minValue(x: m_dBoxedContourData[i][j],y: m_dBoxedContourData[i][j+1])
        var temp2: Int = minValue(x: m_dBoxedContourData[i+1][j], y: m_dBoxedContourData[i+1][j+1])
        dmin = minValue(x: temp1,y: temp2)
        temp1 = maxValue(x: m_dBoxedContourData[i][j],y: m_dBoxedContourData[i][j+1])
        temp2 = maxValue(x: m_dBoxedContourData[i+1][j],y: m_dBoxedContourData[i+1][j+1])
        dmax = maxValue(x: temp1,y: temp2)
        
        if ( Double(dmax) < levels[0] || Double(dmin) > levels[n_levels-1] ) {
          continue
        }
        
        for k in 0 ..< n_levels {
          if (!( levels[k] >= Double(dmin) && levels[k] <= Double(dmax) )) {
            continue
            
          }
          for m in (0 ... 4).reversed() {
            if (m > 0) {
              //=============================================================
              // The indexing of im and jm should be noted as it has to
              // start from zero
              //=============================================================
              let index_y = i + im[m - 1]
              let index_x = j + jm[m - 1]
              h[m] = Double(m_dBoxedContourData[index_y][index_x]) - levels[k]
              
              xh[m] = Double(i + im[m - 1])
              let yh_value = Double(j + jm[m - 1])
              yh[m] = yh_value
            } else {
              h[0] = 0.25 * (h[1] + h[2] + h[3] + h[4])
              xh[0] = 0.5 * Double((i + i + 1))
              yh[0] = 0.5 * Double((j + j + 1))
            }
            
            if (h[m] > 0.0) {
              sh[m] = 1
            } else if (h[m] < 0.0) {
              sh[m] = -1
            } else {
              sh[m] = 0
            }
          }
          
          //=================================================================
          //
          // Note: at this stage the relative heights of the corners and the
          // centre are in the h array, and the corresponding coordinates are
          // in the xh and yh arrays. The centre of the box is indexed by 0
          // and the 4 corners by 1 to 4 as shown below.
          // Each triangle is then indexed by the parameter m, and the 3
          // vertices of each triangle are indexed by parameters m1,m2,and
          // m3.
          // It is assumed that the centre of the box is always vertex 2
          // though this isimportant only when all 3 vertices lie exactly on
          // the same contour level, in which case only the side of the box
          // is drawn.
          //
          //
          //      vertex 4 +-------------------+ vertex 3
          //               | \               / |
          //               |   \    m-3    /   |
          //               |     \       /     |
          //               |       \   /       |
          //               |  m=2    X   m=2   |       the centre is vertex 0
          //               |       /   \       |
          //               |     /       \     |
          //               |   /    m=1    \   |
          //               | /               \ |
          //      vertex 1 +-------------------+ vertex 2
          //
          //
          //
          //               Scan each triangle in the box
          //
          //=================================================================
          
          for m in 1 ..< 5 {
            m1 = m
            m2 = 0
            if (m != 4) {
              m3 = m + 1
            } else {
              m3 = 1
            }
            
            //(레벨보다 높으면 2,같으면1,낮으면0)의 값으로 트라이앵글이 걸치는 방법을 서치
            case_value = castab[sh[m1] + 1][sh[m2] + 1][sh[m3] + 1]
            
            if (case_value != 0) {
              switch (case_value) {
                //===========================================================
                //     Case 1 - Line between vertices 1 and 2
              //===========================================================
              case 1 :
                x1 = xh[m1]
                y1 = yh[m1]
                x2 = xh[m2]
                y2 = yh[m2]
                
                //===========================================================
                //     Case 2 - Line between vertices 2 and 3
              //===========================================================
              case 2 :
                x1 = xh[m2]
                y1 = yh[m2]
                x2 = xh[m3]
                y2 = yh[m3]
                
                //===========================================================
                //     Case 3 - Line between vertices 3 and 1
              //===========================================================
              case 3 :
                x1 = xh[m3]
                y1 = yh[m3]
                x2 = xh[m1]
                y2 = yh[m1]
                
                //===========================================================
                //     Case 4 - Line between vertex 1 and side 2-3
              //===========================================================
              case 4 :
                x1 = xh[m1]
                y1 = yh[m1]
                x2 = xSect(p1: m2, p2: m3, h: h, xh: xh)
                y2 = ySect(p1: m2, p2: m3, h: h, yh: yh)
                
                //===========================================================
                //     Case 5 - Line between vertex 2 and side 3-1
              //===========================================================
              case 5 :
                x1 = xh[m2]
                y1 = yh[m2]
                x2 = xSect(p1: m3, p2: m1, h: h, xh: xh)
                y2 = ySect(p1: m3, p2: m1, h: h, yh: yh)
                
                //===========================================================
                //     Case 6 - Line between vertex 3 and side 1-2
              //===========================================================
              case 6 :
                x1 = xh[m3]
                y1 = yh[m3]
                x2 = xSect(p1: m1, p2: m2, h: h, xh: xh)
                y2 = ySect(p1: m1, p2: m2, h: h, yh: yh)
                
                //===========================================================
                //     Case 7 - Line between sides 1-2 and 2-3
              //===========================================================
              case 7 :
                x1 = xSect(p1: m1, p2: m2, h: h, xh: xh)
                y1 = ySect(p1: m1, p2: m2, h: h, yh: yh)
                x2 = xSect(p1: m2, p2: m3, h: h, xh: xh)
                y2 = ySect(p1: m2, p2: m3, h: h, yh: yh)
                
                //===========================================================
                //     Case 8 - Line between sides 2-3 and 3-1
              //===========================================================
              case 8 :
                x1 = xSect(p1: m2, p2: m3, h: h, xh: xh)
                y1 = ySect(p1: m2, p2: m3, h: h, yh: yh)
                x2 = xSect(p1: m3, p2: m1, h: h, xh: xh)
                y2 = ySect(p1: m3, p2: m1, h: h, yh: yh)
                
                //===========================================================
                //     Case 9 - Line between sides 3-1 and 1-2
              //===========================================================
              case 9 :
                x1 = xSect(p1: m3, p2: m1, h: h, xh: xh)
                y1 = ySect(p1: m3, p2: m1, h: h, yh: yh)
                x2 = xSect(p1: m1, p2: m2, h: h, xh: xh)
                y2 = ySect(p1: m1, p2: m2, h: h, yh: yh)
              default: break
              }
              //=============================================================
              // Put your processing code here and comment out the printf
              //=============================================================
              addSegment(t: SPair(p1: SPoint(x: x1, y: y1), p2: SPoint(x: x2, y: y2)), level: k)
            }
          }
        }
      }
    }
  }
  
  private func addSegment(t : SPair, level: Int)
  {
    // ensure that the object hierarchy has been allocated
    if(contour_level.isEmpty) {
      for _ in 0 ..< n_levels {
        contour_level.append(ContourLevel())
      }
    }
    // push the value onto the end of the vector
    contour_level[level].raw.append(t)  // SPair값을 집어넣음
    //if(cNo==1)TRACE("(*contour_level)[ %d ]->raw->push_back(..) \n",level);
  }
  
  func consolidate() {
    //sort the raw vectors if they exist
    for i in contour_level.indices {
      contour_level[i].consolidate()
    }
  }
  
  private func minValue(x: Int, y: Int)-> Int {
    return (x < y) ? x : y
  }
  
  private func maxValue(x: Int, y: Int)-> Int {
    return (x > y) ? x : y
  }
  
  private func xSect(p1: Int, p2: Int, h: Array<Double>, xh: Array<Double>)-> Double {
    return (h[p2]*xh[p1]-h[p1]*xh[p2])/(h[p2]-h[p1])
  }
  
  private func ySect(p1: Int, p2: Int, h: Array<Double>, yh: Array<Double>)-> Double {
    return (h[p2]*yh[p1]-h[p1]*yh[p2])/(h[p2]-h[p1])
  }
}


class ContourLevel {
  var raw: Array<SPair> = []
  private var contour_lines: Array<Contour> = []
  
  func dump() {
    for it in contour_lines.indices {
      contour_lines[it].dump()
    }
  }
  
  func consolidate() {
    if(raw.count == 0) {return}
    
    
    //raw.sortWith( compareBy<SPair> { it.p1.x }.thenBy { it.p1.y })
    raw.sort(by: {
      if $0.p1.x != $1.p1.x { // first, compare by last names
        return $0.p1.x < $1.p1.x
      } else { // All other fields are tied, break ties by last name
        return $0.p1.y < $1.p1.y
      }
    })
    
    //raw.sort(by: {$0.p1.x < $1.p1.x} )
    //raw.sort(by: {$0.p2.x > $1.p2.x} )
    
    while(!raw.isEmpty)
    {
      let contours = Contour()
      contours.addVector(start: raw[0].p1, end: raw[0].p2)
      raw.remove(at: 0)
      
      var i = 0
      while (i < raw.count) {
        let p1 = raw[i].p1
        let end = contours.end()
        if ((p1.x == end.x) && (p1.y == end.y)) {
          contours.addVector(start: raw[i].p1, end: raw[i].p2)
          raw.remove(at: i)
          i = 0
        } else {
          i += 1
        }
      }
      contour_lines.append(contours)
    }
    
    //잘 안보이지만 merge작업
    merge()
    
    for i in contour_lines.indices {
      contour_lines[i].condense(difference: 0.000000001)
    }
  }
  
  private func merge() {
    if(contour_lines.count < 2) {return}
    
    var index = 0
    var next_index: Int
    var it_contour : Contour
    
    while(index < contour_lines.count) {
      next_index = index + 1
      var next_contour : Contour
      it_contour = contour_lines[index]
      while(next_index < contour_lines.count) {
        next_contour = contour_lines[next_index]
        
        if(it_contour.end().x == next_contour.start().x && it_contour.end().y == next_contour.start().y)
        {
          it_contour.merge(c: next_contour)
          
          contour_lines.remove(at: next_index)
          
          next_index = index + 1
        } else if(next_contour.end().x == it_contour.start().x && next_contour.end().y == it_contour.start().y)
        {
          next_contour.merge(c: it_contour)
          contour_lines[index] = next_contour
          
          contour_lines.remove(at: next_index)
          
          it_contour = contour_lines[index]
          next_index = index + 1
        }
        else if(it_contour.end().x == next_contour.end().x && it_contour.end().y == next_contour.end().y)
        {
          next_contour.reverse()
          it_contour.merge(c: next_contour)
          
          contour_lines.remove(at: next_index)
          next_index = index + 1
        }
        else if(it_contour.start().x == next_contour.start().x && it_contour.start().y == next_contour.start().y)
        {
          it_contour.reverse()
          it_contour.merge(c: next_contour)
          
          contour_lines.remove(at: next_index)
        }
        else {
          next_index += 1
        }
      }
      index += 1
    }
    
  }
}

class Contour {
  private var _start: SPoint = SPoint(x: 0, y: 0)
  private var _end: SPoint = SPoint(x: 0, y: 0)
  private var contour:Array<SVector> = []
  
  func reverse() {
    // swap the start and end points
    let t: SPoint = _end
    _end=_start
    _start=t
    // iterate thru the entire vector and reverse each individual element
    // inserting them into a new vector as we go
    contour.reverse()
    
    for i in contour.indices {
      contour[i].dx = contour[i].dx*(-1)
      contour[i].dy = contour[i].dy*(-1)
    }
  }
  
  func merge(c: Contour) {
    contour.append(contentsOf: c.contour)
    _end = c._end
  }
  
  func addVector(start: SPoint, end: SPoint) {
    let v = SVector(dx: end.x - start.x, dy: end.y - start.y)
    if(contour.count == 0) {_start = start}
    contour.append(v)
    _end = end
  }
  
  func condense(difference: Double) {
    var m1: Double
    var m2: Double
    
    var it : Int = 0
    var jt : Int = 1
    
    while(jt < contour.count){
      if((contour[jt].dx != 0.0) && (contour[it].dx != 0.0))
      {
        m1=contour[jt].dy/contour[jt].dx
        m2=contour[it].dy/contour[jt].dx
      }
      else if((contour[jt].dy != 0.0) && (contour[it].dy != 0.0))
      {
        m1=contour[jt].dx/contour[jt].dy
        m2=contour[it].dx/contour[jt].dy
      }
      else
      {
        it += 1
        jt += 1
        continue
      }
      
      if ((m1-m2<difference)&&(m2-m1<difference))
      {
        contour[it].dx += contour[jt].dx
        contour[it].dy += contour[jt].dy
        contour.remove(at: jt)
      }
      else
      {
        it += 1
        jt += 1
      }
    }
  }
  
  func dump() {
    var p = _start
    
    m_dContourPointX[0] = _start.x
    m_dContourPointY[0] = _start.y
    
    m_nContourPointNum = 1
    
    for cit in contour.indices {
      p.x += contour[cit].dx
      p.y += contour[cit].dy
      m_dContourPointX[m_nContourPointNum] = p.x
      m_dContourPointY[m_nContourPointNum] = p.y
      
      m_nContourPointNum += 1
    }
    
    m_dContourPointX[m_nContourPointNum] = _end.x
    m_dContourPointY[m_nContourPointNum] = _end.y
    m_nContourPointNum += 1
    
    fillContourColor(level: m_nLevel, num: m_nContourPointNum, point_x: m_dContourPointX, point_y: m_dContourPointY)
  }
  
  func start()-> SPoint{
    return _start
  }
  func end()-> SPoint{
    return _end
  }
}

struct SVector {
  var dx: Double
  var dy: Double
}

struct SPair {
  var p1: SPoint
  var p2: SPoint
}

struct SPoint{
  var x: Double
  var y: Double
}

