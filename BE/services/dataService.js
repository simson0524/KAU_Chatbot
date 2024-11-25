const db = require('../config/dbConfig');

exports.saveData = async (data) => {
    const truncateExternalQuery = `
        TRUNCATE TABLE external_notice;
    `;
    const truncateSchoolQuery = `
        TRUNCATE TABLE school_notice;
    `;

    const insertExternalQuery = `
        INSERT INTO external_notice (idx, text, files, url, title, published_date, deadline_date)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    const insertSchoolQuery = `
        INSERT INTO school_notice (idx, text, files, url, title, published_date, deadline_date)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    const connection = await db.getConnection();
    try {
        console.log('Starting transaction...');
        await connection.beginTransaction();

        // 데이터 삭제
        console.log('Truncating external_notice table...');
        await connection.query(truncateExternalQuery);
        console.log('Truncating school_notice table...');
        await connection.query(truncateSchoolQuery);
        console.log('Tables truncated.');

        // 데이터 삽입 전 확인
        const [externalRows] = await connection.query('SELECT COUNT(*) AS count FROM external_notice');
        const [schoolRows] = await connection.query('SELECT COUNT(*) AS count FROM school_notice');
        console.log(`Row count in external_notice after truncate: ${externalRows[0].count}`);
        console.log(`Row count in school_notice after truncate: ${schoolRows[0].count}`);

        // 새 데이터 삽입
        console.log('Inserting new data...');
        for (const row of data) {
            if (row.idx.startsWith('요즘것들_') || row.idx.startsWith('드림스폰_')) {
                await connection.query(insertExternalQuery, [
                    row.idx,
                    row.text,
                    row.files || null,
                    row.url,
                    row.title,
                    row.published_date,
                    row.deadline_date,
                ]);
            } else if (row.idx.startsWith('항공대공지_')) {
                await connection.query(insertSchoolQuery, [
                    row.idx,
                    row.text,
                    row.files || null,
                    row.url,
                    row.title,
                    row.published_date,
                    row.deadline_date,
                ]);
            }
        }

        console.log('Committing transaction...');
        await connection.commit();
        console.log('Transaction committed successfully.');
    } catch (error) {
        console.error('Error during transaction:', error);
        await connection.rollback();
        console.log('Transaction rolled back.');
        throw error;
    } finally {
        connection.release();
    }
};