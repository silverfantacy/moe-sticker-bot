import React, { useEffect, useState } from 'react';
import axios from 'axios';

import { StickerGrid } from './StickerGrid'
import { SortableSticker } from './SortableSticker'

function Export() {
  const [ss, setSS] = useState([])
  const uid = window.Telegram.WebApp.initDataUnsafe.user.id
  const queryId = window.Telegram.WebApp.initDataUnsafe.query_id
  const params = new URLSearchParams(window.location.search)
  const sn = params.get("sn")
  const hex = params.get("hex")

  const host = import.meta.env.VITE_HOST || window.location.host
  const exportParams = new URLSearchParams({ dn: host, sn, qid: queryId, hex })
  const exportLinkHttps = `https://${host}/webapp/api/export?${exportParams.toString()}`
  const exportLinkMsb = `msb://app/export/${encodeURIComponent(sn)}/?dn=${encodeURIComponent(host)}&qid=${encodeURIComponent(queryId)}&hex=${encodeURIComponent(hex)}`

  useEffect(() => {
    const ssParams = new URLSearchParams({ sn, uid, qid: queryId, hex, cmd: "export" })
    axios.get(`/webapp/api/ss?${ssParams.toString()}`)
      .then(res => {
        setSS(res.data.ss)
      })
      .catch(() => { })

    // Android specific bug.
    // Android does not support opening custom scheme link
    // as well as https link from MainButton.
    // Hence, we need to put a button inside WebPage and do not
    // generate MainButton.
    if (window.Telegram.WebApp.platform !== "android") {
      window.Telegram.WebApp.MainButton.setText('Export/匯出').show()
        .onClick(() => {
          window.open(exportLinkMsb)
        })
    }
  }, [exportLinkMsb, hex, queryId, sn, uid])
  return (

    <div>
      {window.Telegram.WebApp.platform !== "ios" ? (
        <button onClick={() => window.location.replace(exportLinkHttps)}>
          Export/匯出
        </button>) : null
      }
      <br/>
      <h3>
        Preview 預覽:
      </h3>
      <StickerGrid columns={4}>
        {
          ss.map((item) => (
            <SortableSticker
              key={item.id}
              id={item.id}
              emoji={item.emoji}
              surl={item.surl} />
          ))
        }
      </StickerGrid>
      <br />
      {window.Telegram.WebApp.platform !== "ios" ? (
        <button onClick={() => window.location.replace(exportLinkHttps)}>
          Export/匯出
        </button>) : null
      }
    </div>
  )
}

export default Export
